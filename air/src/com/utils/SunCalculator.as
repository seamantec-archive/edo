package com.utils {

public class SunCalculator {

    private static var _instance:SunCalculator = null;

    public static const dayMs:Number = 1000 * 60 * 60 * 24;
    private const J1970:Number = 2440588;
    private const J2000:Number = 2451545;
    private const rad:Number = Math.PI/180;
    private const e:Number = rad*23.4397;
    private const J0:Number = 0.0009;

    private var K1:Number = 15*rad*1.0027379

    private var Moonrise:Boolean = false;
    private var Moonset:Boolean  = false;

    private var Rise_time:Array = [0, 0];
    private var Set_time:Array  = [0, 0];

    private var Sky:Array = [0.0, 0.0, 0.0];
    private var RAn:Array = [0.0, 0.0, 0.0];
    private var Dec:Array = [0.0, 0.0, 0.0];
    private var VHz:Array = [0.0, 0.0, 0.0];

    function SunCalculator() {
    }

    public static function get instance():SunCalculator {
        if(_instance==null) {
            _instance = new SunCalculator();
        }
        return _instance;
    }

    public function getSunPosition(date:Date, lat:Number, lng:Number):Object {

        var lw:Number  = rad * -lng;
        var phi:Number = rad * lat;
        var d:Number = toDays(date);

        var c:Object = getSunCoords(d);
        var H:Number = getSiderealTime(d, lw) - c.ra;

        return {
            azimuth: getAzimuth(H, phi, c.dec),
            altitude: getAltitude(H, phi, c.dec)
        };
    }

    public function getSunTimes(date:Date, lat:Number, lng:Number):Object {
        var lw:Number  = rad * -lng;
        var phi:Number = rad * lat;
        var d:Number   = toDays(date);

        var n:Number  = getJulianCycle(d, lw);
        var ds:Number = getApproxTransit(0, lw, n);

        var M:Number = getSolarMeanAnomaly(ds);
        var C:Number = getEquationOfCenter(M);
        var L:Number = getEclipticLongitude(M, C);

        var dec:Number = getDeclination(L, 0);

        var Jnoon:Number = getSolarTransitJ(ds, M, L);

        var Jset:Number = getSetJ(-0.83*rad, phi, dec, lw, n, M, L);
        var Jrise:Number = Jnoon - (Jset - Jnoon);

        return {
            rise: fromJulian(Jrise),
            "set": fromJulian(Jset)
        };
    }

    public function getMoonTimes(date:Date, lat:Number, lon:Number):Object {
        var zone:int = Math.floor(lon/15);
        var jd:Number = julianDay(date.getUTCDate(), date.getUTCMonth() + 1, date.getUTCFullYear());
        var rise:Date = new Date();
        var set:Date = new Date();

        riseset(jd, lat,  lon);

        if(Rise_time[0]==-1 && Rise_time[1]==-1) {
            rise = null;
        } else {
            Rise_time[0] -= zone;
            if(Rise_time[0]<0) {
                Rise_time[0] = 24 + Rise_time[0];
            }
            rise.setUTCHours(Rise_time[0], Rise_time[1]);
        }
        if(Set_time[0]==-1 && Set_time[1]==-1) {
            set = null;
        } else {
            Set_time[0] -= zone;
            if(Set_time[0]<0) {
                Set_time[0] = 24 + Set_time[0];
            }
            set.setUTCHours(Set_time[0], Set_time[1]);
        }

        return { rise: rise, "set": set };
    }

    public function getMoonFraction(date:Date):Number {
        var d:Number = toDays(date);
        var s:Object = getSunCoords(d);
        var m:Object = getMoonCoords(d);

        var sdist:uint = 149598000;

        var phi:Number = Math.acos(Math.sin(s.dec) * Math.sin(m.dec) + Math.cos(s.dec) * Math.cos(m.dec) * Math.cos(s.ra - m.ra));
        var inc:Number = Math.atan2(sdist * Math.sin(phi), m.dist - sdist * Math.cos(phi));

        return (1 + Math.cos(inc)) / 2;
    }

    private function toJulian(date:Date):Number {
        return date.getTime() / dayMs - 0.5 + J1970;
    }

    private function fromJulian(j:Number):Date {
        return new Date((j + 0.5 - J1970) * dayMs);
    }

    private function toDays(date:Date):Number {
        return toJulian(date) - J2000;
    }

    private function getRightAscension(l:Number, b:Number):Number {
        return Math.atan2(Math.sin(l) * Math.cos(e) - Math.tan(b) * Math.sin(e), Math.cos(l));
    }

    private function getDeclination(l:Number, b:Number):Number {
        return Math.asin(Math.sin(b) * Math.cos(e) + Math.cos(b) * Math.sin(e) * Math.sin(l));
    }

    private function getAzimuth(H:Number, phi:Number, dec:Number):Number {
        return Math.atan2(Math.sin(H), Math.cos(H) * Math.sin(phi) - Math.tan(dec) * Math.cos(phi));
    }

    private function getAltitude(H:Number, phi:Number, dec:Number):Number {
        return Math.asin(Math.sin(phi) * Math.sin(dec) + Math.cos(phi) * Math.cos(dec) * Math.cos(H));
    }

    private function getSiderealTime(d:Number, lw:Number):Number {
        return rad * (280.16 + 360.9856235 * d) - lw;
    }

    private function getSolarMeanAnomaly(d:Number):Number {
        return rad * (357.5291 + 0.98560028 * d);
    }

    private function getEquationOfCenter(M:Number):Number {
        return rad * (1.9148 * Math.sin(M) + 0.02 * Math.sin(2 * M) + 0.0003 * Math.sin(3 * M));
    }

    private function getEclipticLongitude(M:Number, C:Number):Number {
        var P:Number = rad * 102.9372;
        return M + C + P + Math.PI;
    }

    private function getSunCoords(d:Number):Object {

        var M:Number = getSolarMeanAnomaly(d);
        var C:Number = getEquationOfCenter(M);
        var L:Number = getEclipticLongitude(M, C);

        return {
            dec: getDeclination(L, 0),
            ra: getRightAscension(L, 0)
        };
    }

    private function getJulianCycle(d:Number, lw:Number):Number {
        return Math.round(d - J0 - lw / (2 * Math.PI));
    }
    private function getApproxTransit(Ht:Number, lw:Number, n:Number):Number {
        return J0 + (Ht + lw) / (2 * Math.PI) + n;
    }
    private function getSolarTransitJ(ds:Number, M:Number, L:Number):Number {
        return J2000 + ds + 0.0053 * Math.sin(M) - 0.0069 * Math.sin(2 * L);
    }
    private function getHourAngle(h:Number, phi:Number, d:Number):Number {
        return Math.acos((Math.sin(h) - Math.sin(phi) * Math.sin(d)) / (Math.cos(phi) * Math.cos(d)));
    }

    private function getSetJ(h:Number, phi:Number, dec:Number, lw:Number, n:Number, M:Number, L:Number):Number {
        var w:Number = getHourAngle(h, phi, dec);
        var a:Number = getApproxTransit(w, lw, n);

        return getSolarTransitJ(a, M, L);
    }

    private function getMoonCoords(d:Number):Object {
        var L:Number = rad * (218.316 + 13.176396 * d);
        var M:Number = rad * (134.963 + 13.064993 * d);
        var F:Number = rad * (93.272 + 13.229350 * d);

        var l:Number  = L + rad * 6.289 * Math.sin(M);
        var b:Number  = rad * 5.128 * Math.sin(F);
        var dt:Number = 385001 - 20905 * Math.cos(M);

        return {
            ra: getRightAscension(l, b),
            dec: getDeclination(l, b),
            dist: dt
        };
    }

    private function julianDay(day:Number, month:Number, year:Number):Number {
        var b:Number;
        var gregorian:Boolean = (year<1583) ? false : true;

        if(month<=2) {
            year  = year  - 1;
            month = month + 12;
        }

        var a:Number = Math.floor(year/100);
        if(gregorian) {
            b = 2 - a + Math.floor(a/4);
        } else {
            b = 0.0;
        }

        return (Math.floor(365.25*(year + 4716)) + Math.floor(30.6001*(month + 1)) + day + b - 1524.5);
    }

    private function sgn(x:Number):Number {
        if(x>0) {
            return 1;
        } else if(x<0) {
            return -1;
        } else {
            return 0;
        }
    }

    private function moon(jd:Number):void {
        var d:Number;
        var f:Number;
        var g:Number;
        var h:Number;
        var m:Number;
        var n:Number;
        var s:Number;
        var u:Number;
        var v:Number;
        var w:Number;

        h = 0.606434 + 0.03660110129*jd;
        m = 0.374897 + 0.03629164709*jd;
        f = 0.259091 + 0.0367481952 *jd;
        d = 0.827362 + 0.03386319198*jd;
        n = 0.347343 - 0.00014709391*jd;
        g = 0.993126 + 0.0027377785 *jd;

        h = h - Math.floor(h);
        m = m - Math.floor(m);
        f = f - Math.floor(f);
        d = d - Math.floor(d);
        n = n - Math.floor(n);
        g = g - Math.floor(g);

        h = h*2*Math.PI;
        m = m*2*Math.PI;
        f = f*2*Math.PI;
        d = d*2*Math.PI;
        n = n*2*Math.PI;
        g = g*2*Math.PI;

        v = 0.39558*Math.sin(f + n);
        v = v + 0.082  *Math.sin(f);
        v = v + 0.03257*Math.sin(m - f - n);
        v = v + 0.01092*Math.sin(m + f + n);
        v = v + 0.00666*Math.sin(m - f);
        v = v - 0.00644*Math.sin(m + f - 2*d + n);
        v = v - 0.00331*Math.sin(f - 2*d + n);
        v = v - 0.00304*Math.sin(f - 2*d);
        v = v - 0.0024 *Math.sin(m - f - 2*d - n);
        v = v + 0.00226*Math.sin(m + f);
        v = v - 0.00108*Math.sin(m + f - 2*d);
        v = v - 0.00079*Math.sin(f - n);
        v = v + 0.00078*Math.sin(f + 2*d + n);

        u = 1 - 0.10828*Math.cos(m);
        u = u - 0.0188 *Math.cos(m - 2*d);
        u = u - 0.01479*Math.cos(2*d);
        u = u + 0.00181*Math.cos(2*m - 2*d);
        u = u - 0.00147*Math.cos(2*m);
        u = u - 0.00105*Math.cos(2*d - g);
        u = u - 0.00075*Math.cos(m - 2*d + g);

        w = 0.10478*Math.sin(m);
        w = w - 0.04105*Math.sin(2*f + 2*n);
        w = w - 0.0213 *Math.sin(m - 2*d);
        w = w - 0.01779*Math.sin(2*f + n);
        w = w + 0.01774*Math.sin(n);
        w = w + 0.00987*Math.sin(2*d);
        w = w - 0.00338*Math.sin(m - 2*f - 2*n);
        w = w - 0.00309*Math.sin(g);
        w = w - 0.0019 *Math.sin(2*f);
        w = w - 0.00144*Math.sin(m + n);
        w = w - 0.00144*Math.sin(m - 2*f - n);
        w = w - 0.00113*Math.sin(m + 2*f + 2*n);
        w = w - 0.00094*Math.sin(m - 2*d + g);
        w = w - 0.00092*Math.sin(2*m - 2*d);

        s = w/Math.sqrt(u - v*v);
        Sky[0] = h + Math.atan(s/Math.sqrt(1 - s*s));
        s = v/Math.sqrt(u);
        Sky[1] = Math.atan(s/Math.sqrt(1 - s*s));
        Sky[2] = 60.40974*Math.sqrt( u );
    }

    private function test_moon(k:Number, t0:Number, lat:Number, plx:Number):Number {
        var ha:Array = [0.0, 0.0, 0.0];
        var a:Number;
        var b:Number;
        var c:Number;
        var d:Number;
        var e:Number;
        var s:Number;
        var z:Number;
        var hr:Number;
        var min:Number;
        var time:Number;

        if(RAn[2]<RAn[0]) {
            RAn[2] = RAn[2] + 2*Math.PI;
        }

        ha[0] = t0 - RAn[0] + k*K1;
        ha[2] = t0 - RAn[2] + k*K1 + K1;

        ha[1]  = (ha[2] + ha[0])/2;
        Dec[1] = (Dec[2] + Dec[0])/2;

        s = Math.sin(rad*lat);
        c = Math.cos(rad*lat);

        z = Math.cos(rad*(90.567 - 41.685/plx));

        if(k<=0) {
            VHz[0] = s*Math.sin(Dec[0]) + c*Math.cos(Dec[0])*Math.cos(ha[0]) - z;
        }

        VHz[2] = s*Math.sin(Dec[2]) + c*Math.cos(Dec[2])*Math.cos(ha[2]) - z;

        if(sgn(VHz[0])==sgn(VHz[2])) {
            return VHz[2];
        }

        VHz[1] = s*Math.sin(Dec[1]) + c*Math.cos(Dec[1])*Math.cos(ha[1]) - z;

        a = 2*VHz[2] - 4*VHz[1] + 2*VHz[0];
        b = 4*VHz[1] - 3*VHz[0] - VHz[2];
        d = b*b - 4*a*VHz[0];

        if(d<0) {
            return VHz[2];
        }

        d = Math.sqrt(d);
        e = (-b + d)/(2*a);

        if((e>1)||(e<0)) {
            e = (-b - d)/(2*a);
        }

        time = k + e + 1/120;
        hr   = Math.floor(time);
        min  = Math.floor((time - hr)*60);

        if(VHz[0]<0 && VHz[2]>0) {
            Rise_time[0] = hr;
            Rise_time[1] = min;
            Moonrise = true;
        }
        if(!Moonrise) {
            Rise_time[0] = -1;
            Rise_time[1] = -1;
        }

        if(VHz[0]>0 && VHz[2]<0) {
            Set_time[0] = hr;
            Set_time[1] = min;
            Moonset = true;
        }
        if(!Moonset) {
            Set_time[0] = -1;
            Set_time[1] = -1;
        }

        return VHz[2];
    }

    private function riseset(jd:Number, lat:Number, lon:Number):void {
        var i:int;
        var j:int;
        var k:int;
        jd -= 2451545;

        var mp:Array = new Array(3);
        for(i=0; i<3; i++) {
            mp[i] = new Array(3);
            for (j=0; j<3; j++) {
                mp[i][j] = 0.0;
            }
        }

        var zone:int = -Math.floor(lon/15);
        lon = lon/360;
        var tz:Number = zone/24;
        var t0:Number = lst(lon, jd, tz);

        jd = jd + tz;

        for(k=0; k<3; k++) {
            moon(jd);
            mp[k][0] = Sky[0];
            mp[k][1] = Sky[1];
            mp[k][2] = Sky[2];
            jd = jd + 0.5;
        }

        if(mp[1][0]<=mp[0][0]) {
            mp[1][0] = mp[1][0] + 2*Math.PI;
        }

        if(mp[2][0]<=mp[1][0]) {
            mp[2][0] = mp[2][0] + 2*Math.PI;
        }

        RAn[0] = mp[0][0];
        Dec[0] = mp[0][1];

        Moonrise = false;
        Moonset  = false;

        for(k=0; k<24; k++) {
            var ph:Number = (k + 1)/24;

            RAn[2] = interpolate(mp[0][0], mp[1][0], mp[2][0], ph);
            Dec[2] = interpolate(mp[0][1], mp[1][1], mp[2][1], ph);

            VHz[2] = test_moon(k, t0, lat, mp[1][2]);

            RAn[0] = RAn[2];
            Dec[0] = Dec[2];
            VHz[0] = VHz[2];
        }
    }

    private function lst(lon:Number, jd:Number, z:Number):Number {
        var s:Number = 24110.5 + 8640184.812999999*jd/36525 + 86636.6*z + 86400*lon;
        s = s/86400;
        s = s - Math.floor(s);
        return (s*360*rad);
    }

    private function interpolate(f0:Number, f1:Number, f2:Number, p:Number):Number {
        var a:Number = f1 - f0;
        var b:Number = f2 - f1 - a;
        return (f0 + p*(2*a + b*(2*p - 1)));
    }

}
}
