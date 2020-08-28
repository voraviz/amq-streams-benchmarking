echo "Enter the name of the new project unique name, this will be used to create the namespace"
read tenant

sed -i '' 's/namespace: .*/namespace: '"$tenant"'/' cluster-operator/*RoleBinding*.yaml
