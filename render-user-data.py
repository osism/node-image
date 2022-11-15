import yaml
from yamlinclude import YamlIncludeConstructor

YamlIncludeConstructor.add_to_loader_class(loader_class=yaml.FullLoader, base_dir='.')

with open('user-data-template') as f:
    data = yaml.load(f, Loader=yaml.FullLoader)

print("#cloud-config")
print(yaml.dump(data))
