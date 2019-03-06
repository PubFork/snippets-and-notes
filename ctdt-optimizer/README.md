# CTDT Optimizer

## Dependencies
```
python>=3.4
pandas>=0.22
ruamel.yaml>=0.15
```

## Interim Executable
```python
# lib/ctdtoptimizer/exec
#!/usr/bin/env python3

import main

main.main()
```

## Inputs
Modify [this](data/params.yaml) locally. Comment out any position dictionaries you do not want to process.

## Roadmap
- Model and code team skills.
- Passive skills.
- Model and code skills (force mult given stam cost and total stam and halftime recovery and then given certain avg num of actions for all players per match weighted by certain positions preferring certain actions since the actions are split out across six or two possibilities).
- Model and code formation bonuses.
- Do Tox.
- Do Travis.
- Do `setup.py`.
- Friendlier interface.
