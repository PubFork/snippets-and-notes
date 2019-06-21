import kubernetes.config as config
import kubernetes.client as client

config.load_kube_config()
api = client.CoreV1Api()

pods = api.list_pod_for_all_namespaces(watch=False)

for pod in pods.items:
    print('Pod IP:', pod.status.pod_ip, '\tNamespace:', pod.metadata.namespace, '\tName:', pod.metadata.name)

nodes = api.list_node(watch=False)

for node in nodes.items:
    print('Name', '\tStatus', '\tRoles', '\tAge', '\tVersion')
    print(node.metadata.name, node.status.conditions[-1].type, '?', '?', node.status.nodeInfo.kubeProxyVersion)
# https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.14/#node-v1-core claims nodeInfo is member of status, but error thrown
