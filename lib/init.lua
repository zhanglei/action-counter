local geoip = require "geoip";
local geoip_country = require "geoip.country";
local geoip_file = "/usr/share/GeoIP/GeoIP.dat" -- "/usr/local/Cellar/geoip/1.5.1/share/GeoIP/GeoIP.dat";
local geoip_country_filename = geoip_file
geodb = geoip_country.open(geoip_country_filename);
