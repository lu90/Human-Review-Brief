# GOVERNANCE-01 HRB Implementation Report

HRB 关联与恢复切片已实现并完成内部代码审查;全局状态及12场景见总控 [Implementation Report](../../../matt-workflow-guidelines/docs/delivery/GOVERNANCE-01_IMPLEMENTATION_REPORT.md) 和聚合 [行为证据](../../../aggregate/docs/delivery/GOVERNANCE-01_ACCEPTANCE_STATUS.md). 本报告不是 Final HRB 或 Owner 批准.

施工采用已安装 engineering-workflow 0.6.0. 固定获批范围为 [Spec@42f1feb](https://github.com/lu90/matt-workflow-guidelines/blob/42f1feb9fa93c45f0d847024468a2cfdc25a37a0/docs/delivery/GOVERNANCE-01_CANDIDATE_SPEC.md) 及其完整 Owner Proposal, 有效 [Owner Decision](https://github.com/lu90/matt-workflow-guidelines/pull/3#issuecomment-5966513122) 为 complete/approve/still_valid. 该决定批准固定 Spec, 不批准 HRB PR #6 或后续实现 HEAD. 原始 Ruby 契约及人类审批没有被新规则取消.

源码: `/workspace/projects/engineering-workflow/Human-Review-Brief`, origin `https://github.com/lu90/Human-Review-Brief.git`, branch `feat/governance-project-context`, base `7caef3543fa526d04efd426c570778425a63f3ea`, [draft PR #6](https://github.com/lu90/Human-Review-Brief/pull/6). 代码审查与初次真实 CI 的实现 HEAD 为 `2f25f958266316ae2ada094145cda7f3267e96f0`. 本报告提交后的实际最终 HEAD、CI checkout/tree 对照与回归收据固定在聚合交接包 `verification/FINAL_VERIFICATION.json`, source-map 固定导出该最终 Git 对象;不在 committed 报告写自指 SHA.

## 需求与文件

| 文件 | 实际改造 |
| --- | --- |
| `docs/HRB-0_PRODUCT_SPEC.md` 5.1/5.2/18.2, `SKILL.md`, `HUMAN.md`, `README.md` | Phase/ChangeSet/scope/shared-contract association;旧记录显式恢复;最小路线不强制 HRB;进入 HRB 后保留全部 Gate |
| `handoffs/fresh-review.md` | 复用 allowlist 槽位, 允许当前权威范围事实;净化 project/迁移/语义检查间接输入, 排除旧 Findings/决定/作者解释/完整报告 |
| `handoffs/remediation-review.md`, `handoffs/brief-compiler.md` | 保持同 PR lineage 与职责;拆分旧 IDs 仅作外部来源映射 |
| `scripts/validate_contracts.rb` | 原函数新增 optional context 形状与固定集合比较;保留原决定/payload/ancestry/head/ready/C01–C23 约束 |
| `fixtures/hrb-0/project-context.example.yaml`, fixture README | 真实函数的关联漂移、旧记录恢复、跨 PR 迁移拒绝与独立新 Round 输入 |
| `docs/agents/issue-tracker.md` | 仅链接总控唯一票据 GOV-01-4, 未新建状态库/另一份票据 |

关联结构为 entry_ref/phase_id/changeset_id/scope_ref/shared_contracts[{ref,revision}], revision 是完整40位小写 Git SHA. 相同契约集合顺序变化或入口定位更新不改批准范围;revision/增删/Phase/ChangeSet/scope 漂移阻断 continuation 和 ready 路线. 旧 Round 可从其 source Decision 对应的主权威批准范围恢复 baseline, 显式作为第六参数;不能覆盖已有 Round snapshot, 缺 baseline 不能用 unchanged 标志通过. 无关联旧记录保持原调用兼容.

新 PR 使用自己的 Round1. 旧 PR/Round/Finding 保留在迁移来源, 不加入新 Round inherited/Decision 集合, 旧批准不可复用成新范围或新 HEAD 批准. 权威远端证据/批准来源的实际验证仍属于 orchestration;Ruby helper 不自动认证远端记录, 与原 Git ancestry 输入边界相同.

## 实际验证与内部审查

原 `.github/workflows/hrb-contracts.yml` 未改: Ubuntu 原 CI 执行 `ruby scripts/validate_contracts.rb`. [run63](https://github.com/lu90/Human-Review-Brief/actions/runs/37106897576), job `111157082316` 成功, 原日志输出 `HRB contract validation passed.`. CI checkout 是 PR 测试 merge `0436adec8bd3dcb55ca9412878f029458a52b816`, 双父为固定 base 与 `2f25f95`;API核验其 tree 与该实现 HEAD 相同, 是测试 checkout, 没有执行源码 PR Merge. 最终报告 commit 的新增 CI 收据见交接包, 不以 run63 冒充未核验最终 HEAD.

C01–C23 与原可执行 self-check block 保留;新增 self-check 实际调用既有 continuation/lineage: linked valid routes, H1拒批H2, pin顺序/locator, revision/增删/ready漂移, legacy恢复/缺baseline/覆盖拒绝, malformed/identity漂移, 同PR lineage, 新PR独立Round及跨PR批准/继承拒绝. 原七份 schema1 YAML、base REVIEW_POLICY、CI workflow字节保持;原 handoff frontmatter/allowlists保持. 本地没有Ruby,本地exit127如实记录;没有用Python/TS模拟器代替该suite,没有语言迁移.

两个独立 `fork_turns:none` Reviewer 对 base...2f25f95 完整固定 diff 分别完成 Standards 和 Spec/正确性审查, HRB切片零未关闭问题. 完整发现/其他仓库整改及最终追加审查见聚合 `GOVERNANCE-01_CODE_REVIEW.md` 与交接包 `verification/FINAL_REVIEW.md`. 当前实际Agent恢复场景8/9读取完整marked合成记录、真实H1→H2 Git、固定共享契约并写下一步/隔离handoff准备;它们没有生成真实GitHub HRB审查或批准.

剩余边界: production平台写入/超时不在合成场景运行,Fresh HRB/Remediation/Compiler和Owner最终决定待原验收窗口执行.本轮没有源码Merge、发布、缓存替换或Skills重载. 聚合导出只读取固定已提交来源, 本仓库继续作为HRB唯一维护源码.
