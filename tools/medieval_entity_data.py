# -*- coding: utf-8 -*-
"""Entity pool for the medieval quiz generator – rich content version."""
from medieval_rich_batch1 import BATCH_R1
from medieval_rich_batch2 import BATCH_R2
from medieval_rich_batch3 import BATCH_R3
from medieval_rich_batch4 import BATCH_R4

# Combine all batches, deduplicate by name_de (last writer wins)
_seen: set[str] = set()
_all: list[dict] = []
for ent in BATCH_R1 + BATCH_R2 + BATCH_R3 + BATCH_R4:
    if ent["name_de"] not in _seen:
        _seen.add(ent["name_de"])
        _all.append(ent)

ENTITIES: list[dict] = _all
