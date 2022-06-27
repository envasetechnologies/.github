import os

import bolt

bolt.register_task('cov', ['nose'])

PROJECT_ROOT = os.path.abspath(os.path.dirname(__file__))
TEST_DIR = os.path.join(PROJECT_ROOT, 'tests')
OUTPUT_DIR = os.path.join(PROJECT_ROOT, 'output')

config = {
    'nose': {
        'directory': TEST_DIR,
        'options': {
            'logging-clear-handlers': True,
        },
    },
}