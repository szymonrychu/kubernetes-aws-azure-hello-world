#!/bin/bash

set -eou nounset

current_aws_acc="$(aws sts get-caller-identity --query Account --output text)"
role_arn="arn:aws:iam::${current_aws_acc}:role/${1:-}"

export $(printf "AWS_ACCESS_KEY_ID=%s AWS_SECRET_ACCESS_KEY=%s AWS_SESSION_TOKEN=%s" \
    $(aws sts assume-role \
    --role-arn ${role_arn} \
    --role-session-name "kubernetes-admin" \
    --duration-seconds 3600 \
    --query 'Credentials.[AccessKeyId,SecretAccessKey,SessionToken]' \
    --output text))
