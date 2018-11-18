# Django Project Package Template Testbed

This is a testbed for the
[django-project-package-template](https://github.com/keimlink/django-project-package-template) Django project template.

It can be used to quickly test the template with development and production-like environments.

## Prerequisites

The following prerequisites are required to create and use the testbed.

*   [GNU Bash](https://www.gnu.org/software/bash/)
*   [GNU Make](https://www.gnu.org/software/make/)
*   [Python 3](https://www.python.org/)

## Usage

### Development Environment

If you want to test the project template in a development environment run the following command:

```console
make migrate createsuperuser runserver
```

It will install the required Python packages, start a new Django project using the project template
and set up the testbed. An random name will be chosen as package name.

Then it will run the database migrations, create a new superuser and start the development web
server.

You can also specify the template manually, e.g. to use a local template using the `TEMPLATE`
environment variable:

```console
TEMPLATE=../django-project-package-template make migrate createsuperuser runserver
```

### Production-Like Environment

To test the project template in a production-like environment run this command:

```console
make server
```

It will create an initial Git commit and check the `MANIFEST.in` file for completeness. Then it
will build the wheel of the project.

After that the production-like environment is created, which includes installing the wheel and
it's dependencies. Then database migrations are run, a new superuser is created and the static
files are collected. Finally the Gunicorn WSGI server is started.

If you only want to build the wheel you can do it by running just this command:

```console
make wheel
```

### Clean Up

To clean up the installed Python packages and the testbed run this command:

```console
make clean
```

## License

Distributed under the 3-Clause BSD License.

Copyright (c) 2018, Markus Zapke-Gründemann
