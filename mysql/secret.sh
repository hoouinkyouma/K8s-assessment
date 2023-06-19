#!/bin/bash

secret_arn="arn:aws:secretsmanager:ap-south-1:590244375483:secret:MySecret-eMlk50"

policy_document='{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "secretsmanager:GetSecretValue",
      "Resource": "'"$secret_arn"'"
    }
  ]
}'

# Create the IAM policy
policy_name="PodSecretAccessPolicy"
policy_arn=$(aws iam create-policy --policy-name "$policy_name" --policy-document "$policy_document" --query 'Policy.Arn' --output text)

# Save the policy ARN in a shell variable
export POLICY_ARN="$policy_arn"

echo "Policy created with ARN: $POLICY_ARN"

# Retrieve and display the secret
secret_value=$(aws secretsmanager get-secret-value --secret-id "$secret_arn" --query 'SecretString' --output text)

echo "Secret value:"
echo "$secret_value"
