package com.map;

public class mappingUtils {
  private double maj;
  private double min;
  private double ecc;

  private double sinSquared(double x) {
    return Math.sin(x) * Math.sin(x);
  }
  
  private double cosSquared(double x) {
    return Math.cos(x) * Math.cos(x);
  }
  
  private double tanSquared(double x) {
    return Math.tan(x) * Math.tan(x);
  }     
 
  private double sec(double x) {
    return 1.0 / Math.cos(x);
  }
  
  private double deg2rad(double x) {
    return x * (Math.PI / 180);
  }
  
  private double rad2deg(double x) {
    return x * (180 / Math.PI);
  }
  
  private void RefEll(double maj, double min) {
    this.maj = maj;
    this.min = min;
    this.ecc = ((maj * maj) - (min * min)) / (maj * maj);
  }

  public String WGS84ToOSGB36(double lat, double lng) {
    // WGS84
    RefEll(6378137.000, 6356752.3141);
    double wgs84_maj = maj;
    double wgs84_min = min;
    double wgs84_ecc = ecc;
    double a        = wgs84_maj;
    double b        = wgs84_min;
    double eSquared = wgs84_ecc;

    double phi = deg2rad(lat);
    double lambda = deg2rad(lng);
    double v = a / (Math.sqrt(1 - eSquared * sinSquared(phi)));
    double H = 0; // height
    double x = (v + H) * Math.cos(phi) * Math.cos(lambda);
    double y = (v + H) * Math.cos(phi) * Math.sin(lambda);
    double z = ((1 - eSquared) * v + H) * Math.sin(phi);

    double tx =       -446.448;
    double ty =        124.157;
    double tz =       -542.060;
    double s  =          0.0000204894;
    double rx = deg2rad(-0.00004172222);
    double ry = deg2rad(-0.00006861111);
    double rz = deg2rad(-0.00023391666);

    double xB = tx + (x * (1 + s)) + (-rx * y)     + (ry * z);
    double yB = ty + (rz * x)      + (y * (1 + s)) + (-rx * z);
    double zB = tz + (-ry * x)     + (rx * y)      + (z * (1 + s));

    // OSGB36
    RefEll(6377563.396, 6356256.909);
    double airy1830_maj = maj;
    double airy1830_min = min;
    double airy1830_ecc = ecc;
    a        = airy1830_maj;
    b        = airy1830_min;
    eSquared = airy1830_ecc;

    double lambdaB = rad2deg(Math.atan(yB / xB));
    double p = Math.sqrt((xB * xB) + (yB * yB));
    double phiN = Math.atan(zB / (p * (1 - eSquared)));
    double phiN1 = 0;
    for (int i = 1; i < 10; i++) {
      v = a / (Math.sqrt(1 - eSquared * sinSquared(phiN)));
      phiN1 = Math.atan((zB + (eSquared * v * Math.sin(phiN))) / p);
      phiN = phiN1;
    }

    double phiB = rad2deg(phiN);
    
    double newLat = phiB;
    double newLng = lambdaB;

    String latLng = String.valueOf(newLat) + "," + String.valueOf(newLng);       
    
    return latLng;
  }

  public String OSGB36ToWGS84(double lat, double lng) {
    // OSGB36
    RefEll(6377563.396, 6356256.909);
    double airy1830_maj = maj;
    double airy1830_min = min;
    double airy1830_ecc = ecc;
    double a        = airy1830_maj;
    double b        = airy1830_min;
    double eSquared = airy1830_ecc;
    double phi = deg2rad(lat);
    double lambda = deg2rad(lng);
    double v = a / (Math.sqrt(1 - eSquared * sinSquared(phi)));
    double H = 0; // height
    double x = (v + H) * Math.cos(phi) * Math.cos(lambda);
    double y = (v + H) * Math.cos(phi) * Math.sin(lambda);
    double z = ((1 - eSquared) * v + H) * Math.sin(phi);
  
    double tx =        446.448;
    double ty =       -124.157;
    double tz =        542.060;
    double s  =         -0.0000204894;
    double rx = deg2rad( 0.00004172222);
    double ry = deg2rad( 0.00006861111);
    double rz = deg2rad( 0.00023391666);
  
    double xB = tx + (x * (1 + s)) + (-rx * y)     + (ry * z);
    double yB = ty + (rz * x)      + (y * (1 + s)) + (-rx * z);
    double zB = tz + (-ry * x)     + (rx * y)      + (z * (1 + s));
 
    // WGS84 
    RefEll(6378137.000, 6356752.3141);
    double wgs84_maj = maj;
    double wgs84_min = min;
    double wgs84_ecc = ecc;
    a        = wgs84_maj;
    b        = wgs84_min;
    eSquared = wgs84_ecc;
  
    double lambdaB = rad2deg(Math.atan(yB / xB));
    double p = Math.sqrt((xB * xB) + (yB * yB));
    double phiN = Math.atan(zB / (p * (1 - eSquared)));
    double phiN1 = 0;
    for (int i = 1; i < 10; i++) {
      v = a / (Math.sqrt(1 - eSquared * sinSquared(phiN)));
      phiN1 = Math.atan((zB + (eSquared * v * Math.sin(phiN))) / p);
      phiN = phiN1;
    }
  
    double phiB = rad2deg(phiN);
      
    double newLat = phiB;
    double newLng = lambdaB;

    String latLng = String.valueOf(newLat) + "," + String.valueOf(newLng);       
    
    return latLng;
  }

  public String OSRefToLatLng(double easting, double northing) {
    RefEll(6377563.396, 6356256.909);
    double OSGB_F0  = 0.9996012717;
    double N0       = -100000.0;
    double E0       = 400000.0;
    double phi0     = deg2rad(49.0);
    double lambda0  = deg2rad(-2.0);
    double a        = this.maj;
    double b        = this.min;
    double eSquared = this.ecc;
    double phi      = 0.0;
    double lambda   = 0.0;
    double E        = easting;
    double N        = northing;
    double n        = (a - b) / (a + b);
    double M        = 0.0;
    double phiPrime = ((N - N0) / (a * OSGB_F0)) + phi0;

    do {
      M =
        (b * OSGB_F0)
          * (((1 + n + ((5.0 / 4.0) * n * n) + ((5.0 / 4.0) * n * n * n))
            * (phiPrime - phi0))
            - (((3 * n) + (3 * n * n) + ((21.0 / 8.0) * n * n * n))
              * Math.sin(phiPrime - phi0)
              * Math.cos(phiPrime + phi0))
            + ((((15.0 / 8.0) * n * n) + ((15.0 / 8.0) * n * n * n))
              * Math.sin(2.0 * (phiPrime - phi0))
              * Math.cos(2.0 * (phiPrime + phi0)))
            - (((35.0 / 24.0) * n * n * n)
              * Math.sin(3.0 * (phiPrime - phi0))
              * Math.cos(3.0 * (phiPrime + phi0))));
      phiPrime += (N - N0 - M) / (a * OSGB_F0);
    } while ((N - N0 - M) >= 0.001);

    double v = a * OSGB_F0 * Math.pow(1.0 - eSquared * sinSquared(phiPrime), -0.5);
    double rho =
      a
        * OSGB_F0
        * (1.0 - eSquared)
        * Math.pow(1.0 - eSquared * sinSquared(phiPrime), -1.5);
    double etaSquared = (v / rho) - 1.0;
    double VII = Math.tan(phiPrime) / (2 * rho * v);
    double VIII =
      (Math.tan(phiPrime) / (24.0 * rho * Math.pow(v, 3.0)))
        * (5.0
          + (3.0 * tanSquared(phiPrime))
          + etaSquared
          - (9.0 * tanSquared(phiPrime) * etaSquared));
    double IX =
      (Math.tan(phiPrime) / (720.0 * rho * Math.pow(v, 5.0)))
        * (61.0
          + (90.0 * tanSquared(phiPrime))
          + (45.0 * tanSquared(phiPrime) * tanSquared(phiPrime)));
    double X = sec(phiPrime) / v;
    double XI =
      (sec(phiPrime) / (6.0 * v * v * v))
        * ((v / rho) + (2 * tanSquared(phiPrime)));
    double XII =
      (sec(phiPrime) / (120.0 * Math.pow(v, 5.0)))
        * (5.0
          + (28.0 * tanSquared(phiPrime))
          + (24.0 * tanSquared(phiPrime) * tanSquared(phiPrime)));
    double XIIA =
      (sec(phiPrime) / (5040.0 * Math.pow(v, 7.0)))
        * (61.0
          + (662.0 * tanSquared(phiPrime))
          + (1320.0 * tanSquared(phiPrime) * tanSquared(phiPrime))
          + (720.0
            * tanSquared(phiPrime)
            * tanSquared(phiPrime)
            * tanSquared(phiPrime)));
    phi =
      phiPrime
        - (VII * Math.pow(E - E0, 2.0))
        + (VIII * Math.pow(E - E0, 4.0))
        - (IX * Math.pow(E - E0, 6.0));
    lambda =
      lambda0
        + (X * (E - E0))
        - (XI * Math.pow(E - E0, 3.0))
        + (XII * Math.pow(E - E0, 5.0))
        - (XIIA * Math.pow(E - E0, 7.0));
   
    double OSRefLat = rad2deg(phi);
    double OSRefLng = rad2deg(lambda);

    //return String.valueOf(OSRefLat) + "," + String.valueOf(OSRefLng);       
    //return WGS84ToOSGB36(OSRefLat, OSRefLng);
    return OSGB36ToWGS84(OSRefLat, OSRefLng);
  }
}
