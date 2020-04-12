#!/usr/bin/env python

from selenium.webdriver.firefox.options import Options
from Mobilenium.mobilenium import mobidriver
from selenium import webdriver
import base64
import psutil
import time
import os

def quit_all(driver):
    # Quit selenium driver
    driver.quit_all()
    # Kill firefox
    for proc in psutil.process_iter():
        if 'firefox-esr' in proc.name():
            proc.kill()
    time.sleep(3)

def get_site(site):
    # Customize Firefox profile
    profile = webdriver.FirefoxProfile()
    # Security preferences
    profile.set_preference('places.history.enabled', False)
    profile.set_preference('privacy.clearOnShutdown.offlineApps', True)
    profile.set_preference('privacy.clearOnShutdown.passwords', True)
    profile.set_preference('privacy.clearOnShutdown.siteSettings', True)
    profile.set_preference('privacy.sanitize.sanitizeOnShutdown', True)
    profile.set_preference('signon.rememberSignons', False)
    profile.set_preference('network.cookie.lifetimePolicy', 2)
    profile.set_preference('network.dns.disablePrefetch', True)
    profile.set_preference('network.http.sendRefererHeader', 0)
    profile.set_preference('browser.safebrowsing.enabled', False)
    profile.set_preference('browser.privatebrowsing.autostart', True)
    # Update preferences
    profile.update_preferences()

    # Intialize driver
    mob = mobidriver.Firefox(browsermob_binary='/home/user/browsermob-proxy-SNAPSHOT/bin/browsermob-proxy', firefox_profile=profile, headless=True, upstream_proxy={'socks5Proxy':'127.0.0.1:9050'})

    # Navigate to page
    mob.get(site)
    # Take and save screenshot
    mob.save_screenshot('screen.png')
    # Output http response data
    print(mob.response)

    quit_all(mob)

get_site('http://check.torproject.org/')
