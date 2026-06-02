#!/usr/bin/python3
import sys
from Bio.PDB import PDBParser
from Bio.PDB.PDBIO import PDBIO
pdb_id    = str(sys.argv[1])
pdb_file  = pdb_id + ".pdb"
parser    = PDBParser()
io        = PDBIO()
structure = parser.get_structure(pdb_id,pdb_file)
chains    = structure.get_chains()
for chain in chains:
    io.set_structure(chain)
    io.save(pdb_id + "_" + chain.get_id() + ".pdb")