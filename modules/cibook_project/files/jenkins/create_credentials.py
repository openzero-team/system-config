import argparse
import socket
import sys

import jenkins
from six.moves.urllib.parse import urlencode
from six.moves.urllib.request import Request

URLENCODE_HEADERS = {'Content-Type': 'application/x-www-form-urlencoded'}
CREDENTIAL_ID = 'credentials/store/system/domain/_/credential/%(id)s/'
CREATE_CREDENTIAL = 'credentials/store/system/domain/_/createCredentials'


class CredJenkins(jenkins.Jenkins):
    def __init__(self, url, username=None, password=None,
                 timeout=socket._GLOBAL_DEFAULT_TIMEOUT):
        super(CredJenkins, self).__init__(url, username, password, timeout)

    def create_credential(self, id, username, private_key=''):
        '''Create a new Jenkins credential
        :param id: id of the credential, ``str``
        :param username: Name of the credential, ``str``
        :param private_key: private key, ``str``
        '''
        if self.credential_exists(id):
           return None

        inner_params = {
            "": "0",
            "credentials": {
                "scope": 'GLOBAL',
                "id": id,
                "username": username,
                "password": "",
                "privateKeySource": {
                    "stapler-class": "com.cloudbees.jenkins.plugins.sshcredentials.impl.BasicSSHUserPrivateKey$DirectEntryPrivateKeySource",
                    "privateKey": private_key,
                },
                "description": "jenkins credentials with private key",
                "stapler-class": "com.cloudbees.jenkins.plugins.sshcredentials.impl.BasicSSHUserPrivateKey"
            }
        }

        params = {
            'json': inner_params
        }

        data = urlencode(params)
        url =self._build_url(CREATE_CREDENTIAL)
        request = Request(url, data, URLENCODE_HEADERS)

        self.jenkins_open(request)
        self.assert_credential_exists(id)

    def credential_exists(self, id):
        if self.get_credential_id(id):
            return True

    def get_credential_id(self, id):
        try:
            response = self.jenkins_open(Request(
                self._build_url(CREDENTIAL_ID, locals())))
        except jenkins.NotFoundException:
            return None
        else:
            return response

    def assert_credential_exists(self, id,
                                 exc_msg='credential[%s] not exist'):
        '''Raise an exception if a job does not exist
        :param name: Name of Jenkins job, ``str``
        :param exception_message: Message to use for the exception. Formatted
                                  with ``name``
        :throws: :class:`JenkinsException` whenever the job does not exist
        '''
        if not self.credential_exists(id):
            raise jenkins.JenkinsException(exc_msg % (id))


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument("-l", "--url",
                        help="jenkins url",
                        required=True)
    parser.add_argument("-u", "--username",
                        help="jenkins username",
                        required=True)
    parser.add_argument("-p", "--password",
                        help="jenkins password",
                        required=True)
    parser.add_argument("-i", "--id",
                        help="id of credential",
                        required=True)
    parser.add_argument("-c", "--cred-username",
                        help="username of credential",
                        required=True)
    parser.add_argument("-k", "--private-key",
                        help="private key of credential",
                        required=True)

    args = parser.parse_args(sys.argv[1:])

    cred_jenkins = CredJenkins(url=args.url,
                               username=args.username,
                               password=args.password)
    cred_jenkins.create_credential(args.id,
                                   args.cred_username,
                                   args.private_key)

