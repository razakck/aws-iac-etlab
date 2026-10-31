import {
  to = aws_s3_bucket.file-storage
  id = "etlab-storage"
}
import {
  to = aws_s3_bucket.tenants
  id = "etlab-tenants"
}
import {
  to = aws_iam_openid_connect_provider.github
  id = "arn:aws:iam::012875038844:oidc-provider/token.actions.githubusercontent.com"
}
# import {
#   to = aws_iam_role.github_actions
#   id = "aws-etlab-iac-github-actions"
# }
# import {
#   to = aws_iam_role_policy.github_actions
#   id = "aws-etlab-iac-github-actions-policy"
# }
import {
  to = aws_iam_role.ec2
  id = "aws-etlab-iac-ec2-role"
}
# import {
#   to = aws_iam_role_policy_attachment.ssm
#   id = "aws-etlab-iac-ec2-ssm"
# }
# import {
#   to = aws_iam_role_policy.ec2_s3
#   id = "aws-etlab-iac-ec2-s3-policy"
# }
import {
  to = aws_iam_instance_profile.ec2
  id = "aws-etlab-iac-ec2-profile"
}
# import {
#   to =  aws_iam_role.codedeploy
#   id = "aws-etlab-iac-codedeploy-role"
# }
# import {
#   to =  aws_iam_role_policy.codedeploy_permissions
#   id = "aws-etlab-iac-codedeploy-permissions"
# }
# import {
#   to =  aws_iam_role_policy_attachment.codedeploy
#   id = "aws-etlab-iac-codedeploy-attachment"
# }

import {
  to =  aws_db_instance.mysql
  id = "aws-etlab-prod-mysql"
}