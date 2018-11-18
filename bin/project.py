#!.venv/bin/python3
import sys

from faker import Faker

fake = Faker()
sys.stdout.write("_".join(fake.words()))
