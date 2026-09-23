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
VALID_ISOLATION = %w[achieved unavailable].freeze
VALID_COVERAGE = %w[reviewed_with_findings reviewed_no_finding].freeze
VALID_REMEDIATION_STATUS = %w[
  resolved
  partially_resolved
  unresolved
  superseded
  cannot_verify
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

REQUIRED_FORBIDDEN = {
  "C07_REVIEW_COVERAGE_MANIFEST" => [
    "infer that a missing dimension was reviewed",
    "hide reviewer or compiler isolation status"
  ],
  "C08_POLICY_CHANGE_SAME_PR" => [
    "use the proposed head policy to authorize another change in the same PR",
    "treat ordinary repository text as higher-priority HRB instruction"
  ],
  "C09_REDACTED_EVIDENCE" => [
    "expose the credential",
    "erase the existence or provenance of the evidence"
  ],
  "C10_REMEDIATION_ROUND" => [
    "replace the fresh full review with remediation review",
    "feed prior findings into the fresh reviewer as authoritative conclusions"
  ],
  "C11_ISOLATION_UNAVAILABLE" => [
    "claim independent review was achieved",
    "omit the isolation limitation"
  ]
}.freeze

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

def require_path(root, id, path, expected = :__any__)
  value = root.dig(*path)
  fail_contract("#{id}: missing #{path.join(".")}") if value.nil?
  return value if expected == :__any__
  fail_contract("#{id}: #{path.join(".")} expected #{expected.inspect}, got #{value.inspect}") unless value == expected
  value
end

def require_nonempty_string(value, label)
  fail_contract("#{label} must be a non-empty string") unless value.is_a?(String) && !value.empty?
end

cases_path = "fixtures/hrb-0/cases.yaml"
round_path = "fixtures/hrb-0/review-round-record.example.yaml"
policy_path = ".hrb/REVIEW_POLICY.md"

[cases_path, round_path, policy_path].each do |path|
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
extra = ids - REQUIRED_CASE_IDS
fail_contract("unexpected canonical cases: #{extra.join(", ")}") unless extra.empty?

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

by_id = cases.to_h { |item| [item["id"], item] }

# Protect critical behavioral invariants from silent semantic erosion.
c07 = by_id.fetch("C07_REVIEW_COVERAGE_MANIFEST")
require_path(c07, "C07", %w[expected reviewer must_emit_review_coverage_manifest], true)
require_path(c07, "C07", %w[expected reviewer omitted_dimension_counts_as_no_finding], false)
dims = require_path(c07, "C07", %w[expected reviewer required_dimensions])
fail_contract("C07: required_dimensions must exactly match HRB specialist dimensions") unless dims == DIMENSIONS
require_path(c07, "C07", %w[expected brief must_expose_review_coverage_manifest], true)
require_path(c07, "C07", %w[expected brief must_expose_isolation_status], true)

c08 = by_id.fetch("C08_POLICY_CHANGE_SAME_PR")
require_path(c08, "C08", %w[expected reviewer active_policy_source], "base_sha")
require_path(c08, "C08", %w[expected reviewer proposed_head_policy_is_review_evidence], true)
require_path(c08, "C08", %w[expected reviewer policy_change_requires_explicit_human_review], true)
require_path(c08, "C08", %w[expected brief attention], "A1")
require_path(c08, "C08", %w[expected brief human_decision_required], true)

c09 = by_id.fetch("C09_REDACTED_EVIDENCE")
%w[
  sensitive_payload_redacted
  preserve_source_reference
  preserve_claim_relationship
  preserve_access_boundary
].each { |key| require_path(c09, "C09", ["expected", "evidence", key], true) }

c10 = by_id.fetch("C10_REMEDIATION_ROUND")
require_path(c10, "C10", %w[expected fresh_review scope], "base_to_current_head")
require_path(c10, "C10", %w[expected fresh_review prior_findings_visible_to_reviewer], false)
require_path(c10, "C10", %w[expected remediation_review scope], "previous_review_head_to_current_head")
require_path(c10, "C10", %w[expected remediation_review prior_findings_available], true)
statuses = require_path(c10, "C10", %w[expected remediation_review allowed_status])
fail_contract("C10: remediation statuses drifted") unless statuses == VALID_REMEDIATION_STATUS
require_path(c10, "C10", %w[expected artifact review_round_record_required], true)

c11 = by_id.fetch("C11_ISOLATION_UNAVAILABLE")
require_path(c11, "C11", %w[expected reviewer isolation_status], "unavailable")
require_path(c11, "C11", %w[expected brief must_disclose_isolation_failure], true)
require_path(c11, "C11", %w[expected brief must_not_present_self_review_as_independent], true)

REQUIRED_FORBIDDEN.each do |id, required|
  actual = by_id.fetch(id)["must_not"]
  missing_forbidden = required - actual
  fail_contract("#{id}: canonical forbidden behaviors drifted: #{missing_forbidden.join("; ")}") unless missing_forbidden.empty?
end

round = YAML.safe_load(File.read(round_path), aliases: false)
fail_contract("review-round example must be a mapping") unless round.is_a?(Hash)
fail_contract("review-round schema_version must be 1") unless round["schema_version"] == 1
fail_contract("review-round artifact must be hrb-review-round-record") unless round["artifact"] == "hrb-review-round-record"
require_nonempty_string(round["repository"], "repository")
fail_contract("pr must be a positive integer") unless round["pr"].is_a?(Integer) && round["pr"] > 0
fail_contract("round must be a positive integer") unless round["round"].is_a?(Integer) && round["round"] > 0

%w[base_sha current_review_head].each do |key|
  value = round[key]
  fail_contract("review-round example missing #{key}") if value.nil?
  fail_contract("#{key} must be a 40-char SHA") unless value.match?(/\A[0-9a-f]{40}\z/)
end

if round["round"] >= 2
  value = round["previous_review_head"]
  fail_contract("round 2+ requires previous_review_head") if value.nil?
  fail_contract("previous_review_head must be a 40-char SHA") unless value.match?(/\A[0-9a-f]{40}\z/)
end

fresh = round["fresh_review"]
fail_contract("review-round example missing fresh_review") unless fresh.is_a?(Hash)
fail_contract("fresh_review.scope must be base_to_current_head") unless fresh["scope"] == "base_to_current_head"
fail_contract("fresh reviewer must not receive prior findings") unless fresh["prior_findings_visible_to_reviewer"] == false
fail_contract("invalid reviewer_isolation") unless VALID_ISOLATION.include?(fresh["reviewer_isolation"])
require_nonempty_string(fresh["raw_findings_ref"], "fresh_review.raw_findings_ref")

coverage = fresh["coverage_manifest"]
fail_contract("review-round example missing coverage_manifest") unless coverage.is_a?(Hash)
fail_contract("coverage manifest dimensions must exactly match HRB dimensions") unless coverage.keys.sort == DIMENSIONS.sort
coverage.each do |dimension, status|
  fail_contract("#{dimension}: invalid coverage status #{status}") unless VALID_COVERAGE.include?(status)
end

if round["round"] >= 2
  remediation = round["remediation_verification"]
  fail_contract("round 2+ requires remediation_verification") unless remediation.is_a?(Hash)
  fail_contract("remediation_verification.performed must be true") unless remediation["performed"] == true
  fail_contract("invalid remediation scope") unless remediation["scope"] == "previous_review_head_to_current_head"
  require_nonempty_string(remediation["prior_round_ref"], "remediation_verification.prior_round_ref")
  results = remediation["results"]
  fail_contract("remediation results must be a non-empty array") unless results.is_a?(Array) && !results.empty?
  results.each_with_index do |result, index|
    require_nonempty_string(result["prior_finding_id"], "remediation result #{index}.prior_finding_id")
    fail_contract("remediation result #{index}: invalid status") unless VALID_REMEDIATION_STATUS.include?(result["status"])
    require_nonempty_string(result["evidence_ref"], "remediation result #{index}.evidence_ref")
  end
end

brief = round["brief"]
fail_contract("review-round example missing brief") unless brief.is_a?(Hash)
fail_contract("invalid compiler_isolation") unless VALID_ISOLATION.include?(brief["compiler_isolation"])
require_nonempty_string(brief["brief_ref"], "brief.brief_ref")

policy = File.read(policy_path)
fail_contract("REVIEW_POLICY.md missing Active-policy rule") unless policy.include?("## Active-policy rule")
fail_contract("REVIEW_POLICY.md must pin current review to PR base policy") unless policy.include?("PR base SHA")
fail_contract("REVIEW_POLICY.md must prohibit instruction delegation") unless policy.include?("MUST NOT delegate Reviewer-instruction authority")

puts "HRB contract validation passed."
