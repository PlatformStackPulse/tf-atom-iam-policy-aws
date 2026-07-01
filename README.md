# tf-atom-iam-policy-aws

[![Terraform Format](https://img.shields.io/badge/terraform-fmt-blue?logo=terraform)](https://github.com/PlatformStackPulse/tf-atom-iam-policy-aws/actions)
[![Terraform Validate](https://img.shields.io/badge/terraform-validate-blue?logo=terraform)](https://github.com/PlatformStackPulse/tf-atom-iam-policy-aws/actions)
[![TFLint](https://img.shields.io/badge/tflint-passing-brightgreen?logo=terraform)](https://github.com/PlatformStackPulse/tf-atom-iam-policy-aws/actions)
[![Terraform Test](https://img.shields.io/badge/tests-2%20passed-brightgreen?logo=terraform)](https://github.com/PlatformStackPulse/tf-atom-iam-policy-aws/actions)
[![Security Scan](https://img.shields.io/badge/trivy-passing-brightgreen?logo=aqua)](https://github.com/PlatformStackPulse/tf-atom-iam-policy-aws/actions)
[![Conventional Commits](https://img.shields.io/badge/commits-conventional-blue?logo=conventionalcommits)](https://conventionalcommits.org)
[![Documentation](https://img.shields.io/badge/docs-terraform--docs-blue?logo=readthedocs)](https://github.com/PlatformStackPulse/tf-atom-iam-policy-aws/actions)
[![License](https://img.shields.io/badge/license-MIT-blue?logo=opensourceinitiative)](LICENSE)

> Terraform atom that creates a single AWS IAM managed policy from a JSON policy document, with tf-label naming/tagging and conditional creation.

---

## Purpose

Creates a single AWS IAM managed policy from a JSON policy document. This atom is the fundamental building block for IAM permission management, designed to be composed with role, user, and group attachment atoms in molecules.

## Architecture

```
┌─────────────────────────────────────────────────┐
│           tf-molecule-iam-service-role-aws       │
│                                                 │
│  ┌─────────────┐  ┌──────────────────────────┐  │
│  │ iam-role    │  │ ▶ iam-policy (THIS ATOM) │  │
│  └──────┬──────┘  └────────────┬─────────────┘  │
│         │                      │                │
│         └──────┐    ┌──────────┘                │
│                ▼    ▼                           │
│  ┌─────────────────────────────────────────┐    │
│  │    iam-role-policy-attachment            │    │
│  └─────────────────────────────────────────┘    │
└─────────────────────────────────────────────────┘
```

## Scope

| In Scope | Out of Scope |
|----------|-------------|
| IAM managed policy creation | Role creation (→ `tf-atom-iam-role-aws`) |
| Policy path configuration | Policy attachment to roles (→ `tf-atom-iam-role-policy-attachment-aws`) |
| JSON policy document validation | Inline role policies (→ `tf-atom-iam-role-policy-aws`) |
| Tags and context propagation | User/group policy attachment (→ companion atoms) |

## Features

- **Single resource** — creates exactly one `aws_iam_policy`
- **Context propagation** — inherits naming and tags from tf-label
- **Conditional creation** — disable with `enabled = false`
- **Composable** — designed to be wired into service-role molecules
- **Validated inputs** — JSON policy + path validation
- **Tested** — unit tests with terraform test framework

## Usage

```hcl
module "lambda_policy" {
  source = "git::https://github.com/PlatformStackPulse/tf-atom-iam-policy-aws.git?ref=v1.0.0"

  namespace   = "acme"
  environment = "prod"
  name        = "lambda-s3-access"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["s3:GetObject", "s3:ListBucket"]
      Resource = ["arn:aws:s3:::my-bucket", "arn:aws:s3:::my-bucket/*"]
    }]
  })
}
```

### Molecule Composition

```hcl
module "policy" {
  source  = "./modules/tf-atom-iam-policy-aws"
  context = module.this.context
  policy  = var.policy_document
}

module "role_attachment" {
  source     = "./modules/tf-atom-iam-role-policy-attachment-aws"
  context    = module.this.context
  role_name  = module.role.role_name
  policy_arn = module.policy.policy_arn
}
```

## Related Atoms

| Atom | Relationship |
|------|-------------|
| [`tf-atom-iam-role-aws`](https://github.com/PlatformStackPulse/tf-atom-iam-role-aws) | Role to attach this policy to |
| [`tf-atom-iam-role-policy-attachment-aws`](https://github.com/PlatformStackPulse/tf-atom-iam-role-policy-attachment-aws) | Wires policy → role |
| [`tf-atom-iam-user-policy-attachment-aws`](https://github.com/PlatformStackPulse/tf-atom-iam-user-policy-attachment-aws) | Wires policy → user |
| [`tf-atom-iam-group-policy-attachment-aws`](https://github.com/PlatformStackPulse/tf-atom-iam-group-policy-attachment-aws) | Wires policy → group |

## CI/CD Workflows

| Workflow | Trigger | Purpose |
|----------|---------|---------|
| `ci.yml` | Push/PR to main | Format, validate, lint, security, test, docs |
| `auto-release.yml` | CI pass on main | Semantic version tag + GitHub Release |
| `codeql.yml` | Push/PR + weekly | Security scanning |
| `changelog.yml` | Release created | Generate CHANGELOG.md |

## Module Documentation

<!-- BEGIN_TF_DOCS -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.11.3 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0.0 |

### Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0.0 |

### Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_this"></a> [this](#module\_this) | git::https://github.com/PlatformStackPulse/tf-label.git | v1.0.0 |

### Resources

| Name | Type |
|------|------|
| [aws_iam_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_policy"></a> [policy](#input\_policy) | JSON-encoded IAM policy document | `string` | n/a | yes |
| <a name="input_attributes"></a> [attributes](#input\_attributes) | ID element. Additional attributes (e.g. `workers` or `cluster`) to add to `id`,<br/>in the order they appear in the list. New attributes are appended to the<br/>end of the list. The elements of the list are joined by the `delimiter`<br/>and treated as a single ID element. | `list(string)` | `[]` | no |
| <a name="input_context"></a> [context](#input\_context) | Single object for setting entire context at once.<br/>See description of individual variables for details.<br/>Leave string and numeric variables as `null` to use default value.<br/>Individual variable settings (non-null) override settings in context object,<br/>except for attributes and tags, which are merged. | <pre>object({<br/>    enabled             = optional(bool, true)<br/>    namespace           = optional(string, null)<br/>    tenant              = optional(string, null)<br/>    environment         = optional(string, null)<br/>    stage               = optional(string, null)<br/>    name                = optional(string, null)<br/>    delimiter           = optional(string, null)<br/>    attributes          = optional(list(string), [])<br/>    tags                = optional(map(string), {})<br/>    label_order         = optional(list(string), null)<br/>    regex_replace_chars = optional(string, null)<br/>    id_length_limit     = optional(number, null)<br/>    label_key_case      = optional(string, null)<br/>    label_value_case    = optional(string, null)<br/>    labels_as_tags      = optional(set(string), null)<br/>    descriptor_formats = optional(map(object({<br/>      format = string<br/>      labels = list(string)<br/>    })), {})<br/>  })</pre> | `{}` | no |
| <a name="input_delimiter"></a> [delimiter](#input\_delimiter) | Delimiter to be used between ID elements.<br/>Defaults to `-` (hyphen). Set to `""` to use no delimiter at all. | `string` | `null` | no |
| <a name="input_description"></a> [description](#input\_description) | Description of the IAM policy. Defaults to module ID if not provided. | `string` | `null` | no |
| <a name="input_descriptor_formats"></a> [descriptor\_formats](#input\_descriptor\_formats) | Describe additional descriptors to be output in the `descriptors` output map.<br/>Map of maps. Keys are names of descriptors. Values are maps of the form<br/>`{<br/>   format = string<br/>   labels = list(string)<br/>}`<br/>`format` is a Terraform format string to be passed to the `format()` function.<br/>`labels` is a list of labels, in order, to pass to `format()` function.<br/>Label values will be normalized before being passed to `format()` so they will be<br/>identical to how they appear in `id`.<br/>Default is `{}` (`descriptors` output will be empty). | <pre>map(object({<br/>    format = string<br/>    labels = list(string)<br/>  }))</pre> | `{}` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Set to false to prevent the module from creating any resources. | `bool` | `null` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | ID element. Usually used for region e.g. 'uw2', 'us-west-2', OR role 'prod', 'staging', 'dev', 'UAT'. | `string` | `null` | no |
| <a name="input_id_length_limit"></a> [id\_length\_limit](#input\_id\_length\_limit) | Limit `id` to this many characters (minimum 6).<br/>Set to `0` for unlimited length.<br/>Set to `null` to keep the existing setting, which defaults to `0`.<br/>Does not affect `id_full`. | `number` | `null` | no |
| <a name="input_label_key_case"></a> [label\_key\_case](#input\_label\_key\_case) | Controls the letter case of the `tags` keys (label names) for tags generated by this module.<br/>Does not affect keys of tags passed in via the `tags` input.<br/>Possible values: `lower`, `title`, `upper`.<br/>Default value: `title`. | `string` | `null` | no |
| <a name="input_label_order"></a> [label\_order](#input\_label\_order) | The order in which the labels (ID elements) appear in the `id`.<br/>Defaults to ["namespace", "environment", "stage", "name", "attributes"].<br/>You can omit any of the 6 labels ("tenant" is the 6th), but at least one must be present. | `list(string)` | `null` | no |
| <a name="input_label_value_case"></a> [label\_value\_case](#input\_label\_value\_case) | Controls the letter case of ID elements (labels) as included in `id`,<br/>set as tag values, and output by this module individually.<br/>Does not affect values of tags passed in via the `tags` input.<br/>Possible values: `lower`, `title`, `upper` and `none` (no transformation).<br/>Set this to `title` and set `delimiter` to `""` to yield Pascal Case IDs.<br/>Default value: `lower`. | `string` | `null` | no |
| <a name="input_labels_as_tags"></a> [labels\_as\_tags](#input\_labels\_as\_tags) | Set of labels (ID elements) to include as tags in the `tags` output.<br/>Default is to include all labels.<br/>Tags with empty values will not be included in the `tags` output.<br/>Set to `[]` to suppress all generated tags.<br/>Note: The value of the `name` tag, if included, will be the `id`, not the `name`. | `set(string)` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | ID element. Usually the component or solution name, e.g. 'app' or 'jenkins'.<br/>This is the only ID element not also included as a `tag`.<br/>The "name" tag is set to the full `id` string. There is no tag with the value of the `name` input. | `string` | `null` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | ID element. Usually an abbreviation of your organization name, e.g. 'eg' or 'cp', to help ensure generated IDs are globally unique. | `string` | `null` | no |
| <a name="input_path"></a> [path](#input\_path) | Path for the IAM policy (e.g., /, /service-role/) | `string` | `"/"` | no |
| <a name="input_regex_replace_chars"></a> [regex\_replace\_chars](#input\_regex\_replace\_chars) | Terraform regular expression (regex) string.<br/>Characters matching the regex will be removed from the ID elements.<br/>If not set, `"/[^a-zA-Z0-9-]/"` is used to remove all characters other than hyphens, letters and digits. | `string` | `null` | no |
| <a name="input_stage"></a> [stage](#input\_stage) | ID element. Usually used to indicate role, e.g. 'prod', 'staging', 'source', 'build', 'test', 'deploy', 'release'. | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags (e.g. `{'BusinessUnit': 'XYZ'}`).<br/>Neither the tag keys nor the tag values will be modified by this module. | `map(string)` | `{}` | no |
| <a name="input_tenant"></a> [tenant](#input\_tenant) | ID element. A customer identifier, indicating who this instance of a resource is for. | `string` | `null` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_enabled"></a> [enabled](#output\_enabled) | Whether the module is enabled |
| <a name="output_policy_arn"></a> [policy\_arn](#output\_policy\_arn) | ARN of the IAM policy |
| <a name="output_policy_id"></a> [policy\_id](#output\_policy\_id) | ID of the IAM policy |
| <a name="output_policy_name"></a> [policy\_name](#output\_policy\_name) | Name of the IAM policy |
<!-- END_TF_DOCS -->

## Tests

Unit tests use the native `terraform test` framework with a mocked AWS provider (no real
AWS calls, no credentials required). Assertions cover only plan-known values — the
tf-label `id` used as the policy name (`eg-test-thing`), resource count, and the
`enabled` output — since computed attributes such as `arn`/`policy_id` are unknown under a
mock provider.

```bash
# Unit tests (mocked provider, no AWS credentials)
make test-unit
# or directly:
terraform init -backend=false
terraform test -test-directory=tests/unit

# Integration tests (real AWS credentials required)
make test-integration
```

Covered scenarios:

| Test | Asserts |
|------|---------|
| `creates_when_enabled` | `enabled == true`, exactly one `aws_iam_policy` planned, `policy_name == "eg-test-thing"` |
| `disabled_creates_nothing` | `enabled == false`, zero resources planned, `policy_arn == null` |

## Contributing

1. Create feature branch from main
2. Run `make fmt && make lint && make docs && make test`
3. Submit PR — CI must pass before merge
4. Squash merge to main triggers auto-release
