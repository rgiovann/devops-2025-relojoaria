# Makefile - Automação CloudFormation (AWS)

STACK_NAME := relojoaria-aws-stack
REGION := us-east-2
TEMPLATE := relojoaria_aws.yaml
VPC_ID := vpc-01367bb93348e0739
SUBNET_ID := subnet-07bb7ef82389821ab
KEY_NAME := leopoldo-final-iac

.PHONY: run destroy status validate ip

run: validate
	@echo "==> Criando stack $(STACK_NAME)..."
	aws cloudformation create-stack \
		--stack-name $(STACK_NAME) \
		--region $(REGION) \
		--template-body file://$(TEMPLATE) \
		--parameters \
			ParameterKey=VpcId,ParameterValue=$(VPC_ID) \
			ParameterKey=SubnetId,ParameterValue=$(SUBNET_ID) \
			ParameterKey=KeyName,ParameterValue=$(KEY_NAME) \
		--capabilities CAPABILITY_IAM
	@echo "==> Aguardando criacao da stack..."
	aws cloudformation wait stack-create-complete \
		--stack-name $(STACK_NAME) \
		--region $(REGION)
	@echo "==> Stack criada com sucesso!"
	$(MAKE) ip

destroy:
	@echo "==> Excluindo stack $(STACK_NAME)..."
	aws cloudformation delete-stack \
		--stack-name $(STACK_NAME) \
		--region $(REGION)
	@echo "==> Aguardando exclusao da stack..."
	aws cloudformation wait stack-delete-complete \
		--stack-name $(STACK_NAME) \
		--region $(REGION)
	@echo "==> Stack removida."

status:
	aws cloudformation describe-stacks \
		--stack-name $(STACK_NAME) \
		--region $(REGION) \
		--query "Stacks[0].StackStatus" \
		--output text

validate:
	aws cloudformation validate-template \
		--template-body file://$(TEMPLATE)

ip:
	@echo "==> Obtendo IP publico..."
	@IP=$$(aws cloudformation describe-stacks \
		--stack-name $(STACK_NAME) \
		--region $(REGION) \
		--query "Stacks[0].Outputs[?OutputKey=='PublicIp'].OutputValue" \
		--output text); \
	echo "Aplicacao disponivel em: http://$$IP:8080"

