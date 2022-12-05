import yaml
from yamlinclude import YamlIncludeConstructor

YamlIncludeConstructor.add_to_loader_class(loader_class=yaml.FullLoader, base_dir='.')

with open('user-data-template') as f:
    data = yaml.load(f, Loader=yaml.FullLoader)

flat_list = list()

for sub_list in data['autoinstall']['user-data']['runcmd']:
    if sub_list:
        flat_list += sub_list

data['autoinstall']['user-data']['runcmd'] = flat_list

print("#cloud-config")
print(yaml.dump(data))
