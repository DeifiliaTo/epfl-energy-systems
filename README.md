# Modelling and Optimisation of Energy Systems

Group B for [`ME-454`](https://edu.epfl.ch/coursebook/en/modelling-and-optimization-of-energy-systems-ME-454) 2019–20 at EPFL

## Links

- [Moodle](https://moodle.epfl.ch/course/view.php?id=11)
- [Mattermost channel](https://ipese-mattermost.epfl.ch/moes2020/pl/6xqf6uji8irc7pxf7bhn5eyi4c)
- [Overleaf](https://www.overleaf.com/8328823628wcqcbfmkzgqz)
- [Zotero](https://www.zotero.org/groups/2480520/me-454_energy_systems/library)
- [Google Drive](https://drive.google.com/drive/u/1/folders/0ANrl5bCKOcwEUk9PVA)

## Code standards


- make sure to **comment** your code

  - equation numbers & section references from the handout
  - include units to the right of a variable being assigned

  for example, like this
  ```matlab
  % Index and variable definition
  index = find(ismember(name, building_name));
  Build.ground = data{1,3}(index);    % Building heated surface [m2]
  Build.Q = data{1,4}(index);         % Building annual heat load [kWh]
  ```
- write **descriptive commit messages**
- name variables consistently
