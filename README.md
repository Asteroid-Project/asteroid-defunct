#The Asteroid open-source mobile operating system project.

Why Asteroid ?
==============
  There has already been many open-source mobile operating system attempts which
were all commercial failures (namely Maemo, Moblin, LiMo, Meego...). There are
also many impressive and promising projects which are currently trying to
achieve the same goal (namely Sailfish OS, Mer, Firefox OS, Tizen, Ubuntu...)
Asteroid could be "Yet another Linux mobile operating system" among others,
but here is why Asteroid is different.

  These projects all have in common the will to be widespread, popular, to
attract the masses, or even to be sold. But we think that Android and iOS are 
already doing it pretty well. All the previous attempts failed because they only
focused on the already saturated market's competition. They forgot the open side
that could make them so great. Asteroid is not maintained by a large corporation
for profit, in fact no company could be interested in buying or selling Asteroid
But we are not serious people in business suits. We do it only for our own needs
and in the hope that someone else will find it useful.

  Asteroid is the mobile OS "of the geeks, by the geeks, for the geeks". Like a
RaspberryPi or Arduino, it is open, hackable and modular and that's why it
unleashes creativity.

  So "Why Asteroid?", Because it's fun.

Why "Asteroid" ?
================
  Some say it stands for Android + Steroids. However it's more the poetic image
of a small lonely rock wandering around without goal. Nobody really cares about
it, but it is still very powerful.

What's under the hood ?
=======================
* Linux: The well known kernel that empowers everything from supercomputers to
satellites, without forgeting nerds personal laptops.
* GNU tools: This often forgotten part of the open-source community which makes
all the fun possible.
* A tty: Yes, the good old tty that has saved computers lifes for years. So 
useful to recover failures, it has now been cleverly adapted to mobile devices.
* Wayland: The most recent standard in open-source windowing system. Recognized
by everyone as the X.org's successor.
* Libhybris: A wonderful piece of software developed by Carsten Munk for Mer and
later Jolla which allows Asteroid to be fully compatible with every Android
drivers and devices.
* Kuiper: A new packager system specificaly designed for Asteroid with new ideas
in mind.
* Low level tools: Small but useful scripts that makes Asteroid's administration
a pleasure.
* Custom tree: Inspired by GoboLinux, Asteroid adopts a more modern tree which
is still compatible with UNIX thanks to a kernel patch.
* Fun: Universaly recognized as the strongest force behind open-source projects.

How can I test Asteroid ?
=========================
  For now, Asteroid is only available on the "Goldfish" platform (which is the 
QEMU-based Android emulator). You can download the build system via git using
these commands :

    git clone https://github.com/Asteroid-Project/Asteroid.git
    cd Asteroid/

  And run a build using this line :

	./build

  When the command is finished, you can emulate Asteroid with :

	./emulate

How can I contribute to Asteroid ?
==================================
  The Asteroid Operating system is a very large project and involves many
activities for every level of difficulties. You can help in many ways, for
example you can:

- Port Asteroid to new platforms
- Create user-end applications
- Package new softwares and libraries
- Translate Asteroid to new languages
- Test as much as you can and report bugs
- Help or debate on IRC

Remember that it's your work that makes Asteroid different.

                                                                Have fun!
