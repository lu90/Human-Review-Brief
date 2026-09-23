#!/usr/bin/env ruby
# frozen_string_literal: true

require "yaml"

VALID_ATTENTION = %w[A1 A2 A3 A4].freeze
VALID_EVIDENCE_ROLES = %w[
  spec_anchor
  base_anchor
  diff_anchor
  head_anchor
  test_anchor
  ci_anchor
  absence_evidence
].freeze

REQUIRED_CASE_IDS = %w[
  C01_FORMATTING_ONLY
  C02_PUBLIC_API_BREAK
  C03_AUTH_GUARD_REMOVED
  C04_LOCAL_REFACTOR_VERIFIED
  C05_LARGE_MIGRATION_MANY_A1
  C06_REPOSITORY_PROMPT_INJECTION
  C07_REVIEW_COVERAGE_MANIFEST
  C08_POLICY_CHANGE_SAME_PR
  C09_REDACTED_EVIDENCE
  C10_REMEDIATION_ROUND
  C11_ISOLATION_UNAVAILABLE
].freeze

DIMENSIONS = %w[
  spec_scope
  architecture_correctness
  tests_verification
  security_privacy
  data_migrations
  operations_observability
  performance_compatibility
  adversarial_challenge
].freeze

def fail_contract(message)
  warn "HRB contract validation failed: #{message}"
  exit 1
end

def walk(value, path = [], &block)
  yield value, path
  case value
  when Hash
    value.each { |key, child| walk(child, path + [key.to_s], &block) }
  when Array
    value.each_with_index { |child, index| walk(child, path + [index.to_s], &block) }
  end
end

cases_path = "fixtures/hrb-0/cases.yaml"
round_path = "fixtures/hrb-0/review-round-record.example.yaml"
policy_path = ".hrb/REVIEW_POLICY.md"

[ cases_path, round_path, policy_path ].each do |path|
  fail_contract("missing #{path}") unless File.file?(path)
end

suite = YAML.safe_load(File.read(cases_path), aliases: false)
fail_contract("cases.yaml must be a mapping") unless suite.is_a?(Hash)
fail_contract("version must be 1") unless suite["version"] == 1
fail_contract("suite must be HRB-0") unless suite["suite"] == "HRB-0"

cases = suite["cases"]
fail_contract("cases must be a non-empty array") unless cases.is_a?(Array) && !cases.empty?

ids = cases.map { |item| item["id"] }
fail_contract("case ids must be unique") unless ids.uniq.length == ids.length
missing = REQUIRED_CASE_IDS - ids
fail_contract("missing required canonical cases: #{missing.join(", ")}") unless missing.empty?

cases.each do |item|
  id = item["id"]
  fail_contract("case missing id") unless id.is_a?(String) && id.match?(/\AC\d{2}_[A-Z0-9_]+\z/)
  fail_contract("#{id}: missing title") unless item["title"].is_a?(String) && !item["title"].empty?
  fail_contract("#{id}: missing input") unless item["input"].is_a?(Hash)
  fail_contract("#{id}: missing expected") unless item["expected"].is_a?(Hash)
  fail_contract("#{id}: must_not must be a non-empty array") unless item["must_not"].is_a?(Array) && !item["must_not"].empty?

  walk(item) do |value, path|
    key = path.last
    if key == "attention"
      fail_contract("#{id}: invalid attention #{value}") unless VALID_ATTENTION.include?(value)
    elsif key == "allowed_attention"
      unless value.is_a?(Array) && value.all? { |entry| VALID_ATTENTION.include?(entry) }
        fail_contract("#{id}: invalid allowed_attention")
      end
    elsif key == "evidence_roles"
      unless value.is_a?(Array) && value.all? { |entry| VALID_EVIDENCE_ROLES.include?(entry) }
        fail_contract("#{id}: invalid evidence_roles")
      end
    end
  end
end

round = YAML.safe_load(File.read(round_path), aliases: false)
required_round_keys = %w[
  schema_version
  artifact
  repository
  pr
  round
  base_sha
  current_review_head
  fresh_review
  brief
]
required_round_keys.each do |key|
  fail_contract("review-round example missing #{key}") unless round.key?(key)
end

%w[base_sha current_review_head previous_review_head].each do |key|
  next if round[key].nil?
  fail_contract("#{key} must be a 40-char SHA") unless round[key].match?(/\A[0-9a-f]{40}\z/)
end

coverage = round.dig("fresh_review", "coverage_manifest")
fail_contract("review-round example missing coverage_manifest") unless coverage.is_a?(Hash)
missing_dimensions = DIMENSIONS - coverage.keys
fail_contract("coverage manifest missing dimensions: #{missing_dimensions.join(", ")}") unless missing_dimensions.empty?

policy = File.read(policy_path)
fail_contract("REVIEW_POLICY.md missing Active-policy rule") unless policy.include?("## Active-policy rule")
fail_contract("REVIEW_POLICY.md must pin current review to PR base policy") unless policy.include?("PR base SHA")

puts "HRB contract validation passed."
