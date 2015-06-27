from setuptools import setup

def readme():
    with open('README.rst') as f:
        return f.read()

setup(name='covariance',
      version='0.1',
      description='estiamtion of the covariance matrix',
      long_description=readme(),
      classifiers=[
        'Development Status :: 1 - Alpha',
        'Environment :: Console',
        'Environment :: X11 Applications',
        'License :: OSI Approved :: GNU General Public License (GPL)',
        'Programming Language :: Python :: 2.7 :: chimera',
        'Intended Audience :: End Users/Desktop',
      ],
      keywords='covariance estimation cryo-EM',
      author='Hstau Y Liao',
      platform='linux chimera',
      author_email='hstau.y.liao@gmail.com',
      packages=['covariance'],
      include_package_data=True,
      zip_safe=False)
