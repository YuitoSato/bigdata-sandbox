-- Secret Managerのaurora uriを書き換えること
-- https://ap-northeast-1.console.aws.amazon.com/secretsmanager/home?region=ap-northeast-1#!/listSecrets/
CREATE EXTERNAL SCHEMA aurora
FROM POSTGRES
DATABASE 'postgres'
SCHEMA 'public'
URI 'AURORA_URI'
PORT 5432
IAM_ROLE 'arn:aws:iam::060507316679:role/bigdata-sandbox-redshift-role'
SECRET_ARN 'arn:aws:secretsmanager:ap-northeast-1:060507316679:secret:bigdata-sandbox-aurora-cluster-secret-l5TLDU';
