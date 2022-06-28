import os

import bolt
import bolt_ptrelease

bolt.register_module_tasks(bolt_ptrelease)

def post_release(config, *args, **kwargs):
    print('Posting Release')

bolt.register_task('cov', ['nose'])
bolt.register_task('post-release', ['_check-release', '_post-release'])
bolt.register_task('_check-release', [
    'check-release-branch',
    'check-release-version'
])
bolt.register_task('_post-release', post_release)

PROJECT_ROOT = os.path.abspath(os.path.dirname(__file__))
TEST_DIR = os.path.join(PROJECT_ROOT, 'tests')
OUTPUT_DIR = os.path.join(PROJECT_ROOT, 'output')
# Vars
RELEASE_BRANCH = 'master'
CURRENT_BRANCH = os.environ.get('BRANCH_NAME') or 'NO-RELEASE'
VERSION_TAG = f'T1.0'

config = {
    'nose': {
        'directory': TEST_DIR,
        'options': {
            'logging-clear-handlers': True,
        },
    },
    'setup': {
        'command': 'bdist_wheel'
    },
    'check-release-branch': {
        'release-branch': RELEASE_BRANCH,
        'current-branch': CURRENT_BRANCH,
    },
    'check-release-version': {
        'version': VERSION_TAG
    },
}
