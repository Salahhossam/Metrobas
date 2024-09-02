package com.transportation.metrobas.util;


import java.math.BigDecimal;

public class DistanceFromStop {

    public static double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
        // Convert latitude and longitude from degrees to radians
        double lat1Rad = Math.toRadians(lat1);
        double lon1Rad = Math.toRadians(lon1);
        double lat2Rad = Math.toRadians(lat2);
        double lon2Rad = Math.toRadians(lon2);

        // Calculate differences
        double latDiff = lat2Rad - lat1Rad;
        double lonDiff = lon2Rad - lon1Rad;

        // Calculate the distance using the Haversine formula
        // Calculate the distance using the Haversine formula
        double a = Math.sin(latDiff / 2) * Math.sin(latDiff / 2)
                + Math.cos(lat1Rad) * Math.cos(lat2Rad)
                * Math.sin(lonDiff / 2) * Math.sin(lonDiff/ 2);
        double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));

        return 6371 * c * 1000;
    }

    public static double getMinDistance(double lat1, double lon1, double lat2, double lon2){
        return calculateDistance(lat1,lon1, lat2, lon2);
    }
}
