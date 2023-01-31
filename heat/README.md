# openstack/heat self hosted github runner

Stack Openstack/Heat de déploiement d un pool de self hosted github runner

Optionnel:
- Nombre de runner dans le pool
- Instance avec "boot on volume"
- Access ssh optionnel vers un bastion dans le subnet des runners
- Si ssh est activé, les ressources suivantes : Floating IP, LoadBalancer, bastion sont activés
  - Le provider de loadbalancer  et l algorithm de repartition sont configurable (`default amphora/ROUND_ROBIN ou ovn/SOURCE_IP_PORT `)

## Déploiement
Pre requis:
- version de l api heat/openstack (> rocky)
- cli openstack installée (ou accès à horizon)
- credentials openstack variable `OS_`

```bash
export OS_IDENTITY_API_VERSION
export OS_PASSWORD
export OS_PROJECT_NAME
export OS_USER_DOMAIN_NAME
export OS_PROJECT_ID
export OS_USERNAME
export OS_AUTH_URL
export OS_INTERFACE
export OS_PROJECT_DOMAIN_ID
export OS_REGION_NAME
```

- Fichier de parametres contenant les variables de l environnement

```yaml
# sample.yaml
parameter_defaults:
  # Uncomment to Enable boot on volume for instance
  #boot_on_volume: "true"
  # Uncomment to Enable SSH to bastion and runners
  #enable_fip: "true"
  # Nombre de runner dans le pool
  runner_count: 2
  keypair_name: runner
  keypair_public_key: "SSH_Pub_key"
  ssh_authorized_keys: [
    {"user":"user1", "key": "SSH_Pub_key_FOR User1"}
    ]
  # Caracteristiques des runners
  # Suffixe du nom des instances
  runner_env: my-env
  runner_image: "Ubuntu 20.04"
  runner_flavor: s1-2
  runner_vol_size: 30
  runner_vol_type: classic
  # Enregistrement des runners
  GH_URL: "URL repo or orga to add runner pool"
  GH_TOKEN: "TOKEN_used_to_add_runner"
  GH_LABEL: "LABEL_FOR_RUNNER_POOL"
```

Pour déployer en cli openstack:
```bash
# creation de la stack
openstack stack create --wait -t heat.yaml -e env.yaml -e sample.yaml runner
```

```bash
# affichage des outputs de la stack (ip, floating ip list)
openstack stack output show --all runner
```

```bash
# Mise à jour de la stack
openstack stack update --wait -t heat.yaml -e env.yaml -e sample.yaml runner
```

```bash
# Suppression de la stack
openstack stack delete -y --wait runner
```


## reference:

- https://docs.openstack.org/heat/latest/template_guide/openstack.html
- https://docs.openstack.org/heat/latest/template_guide/hot_spec.html
- https://docs.openstack.org/heat/latest/template_guide/environment.html
