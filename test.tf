module.restricted_trading_list_service.module.aurora_mysql_serverlessv2.module.aurora_mysql_serverlessv2.random_id.snapshot_identifier[0]: Refreshing state... [id=JxluIw]
module.restricted_trading_list_service.module.aurora_mysql_serverlessv2.module.aurora_mysql_serverlessv2.random_id.snapshot_identifier[0]: Refreshing state... [id=JxluIw]

Terraform used the selected providers to generate the following execution
plan. Resource actions are indicated with the following symbols:
  + create
  ~ update in-place
  - destroy
-/+ destroy and then create replacement
+/- create replacement and then destroy
 <= read (data resources)

Terraform will perform the following actions:

  # module.restricted_trading_list_service.aws_s3_bucket_notification.bucket_notification will be updated in-place
  ~ resource "aws_s3_bucket_notification" "bucket_notification" {
        id          = "nc-dev-trevorb-sb-rtlsvc-files"
        # (2 unchanged attributes hidden)

      ~ lambda_function {
          ~ events              = [
              - "s3:ObjectCreated:*",
              + "s3:ObjectCreated:CompleteMultipartUpload",
              + "s3:ObjectCreated:Put",
            ]
            id                  = "tf-s3-lambda-20220815193323808800000003"
            # (2 unchanged attributes hidden)
        }
    }
