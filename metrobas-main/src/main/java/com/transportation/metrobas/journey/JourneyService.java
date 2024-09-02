package com.transportation.metrobas.journey;

import java.math.BigDecimal;
import java.time.LocalTime;
import java.util.*;
import java.util.stream.Collectors;

import com.transportation.metrobas.enums.Transportation;
import com.transportation.metrobas.gtfs.*;
import com.transportation.metrobas.util.DistanceFromStop;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class JourneyService {

    private final StopRepository stopRepository;

    private final TransfersRepository transfersRepository;

    private final TripRepository tripRepository;

    private final TripPointsRepository tripPointsRepository;

    private final List<Stop> allStops;

    private final Map<Stop, Map<Stop, Double>> transfersDict;

    private final Map<String, List<StopTimes>> TripWithStopsMap;

    private final int MAX_TRANSFER = 4;

    private final Map<Transportation, ArrayList<String>> TransportationsDictionary ;

    private final MCRaptor mcRaptor;

    @Autowired
    public JourneyService(StopRepository stopRepository, TransfersRepository transfersRepository,
                          TripRepository tripRepository, TripPointsRepository tripPointsRepository ,MCRaptor mcRaptor) {
        this.stopRepository = stopRepository;
        this.tripRepository = tripRepository;
        this.tripPointsRepository = tripPointsRepository;
        this.transfersRepository = transfersRepository;

        this.allStops = this.stopRepository.getAllStopsWithStopTimes();
        this.TripWithStopsMap = this.getTripWithStopsMap();
        this.transfersDict = getTrsanfers(this.transfersRepository.findAllWithTransferStops());

        this.mcRaptor = mcRaptor;

        TransportationsDictionary = new HashMap<>();
        TransportationsDictionary.put(Transportation.BUS, new ArrayList<>(Arrays.asList("AGY", "BOX", "CTA", "COOP", "CTA_M", "GRN")));
        TransportationsDictionary.put(Transportation.MICROBUS, new ArrayList<>(Arrays.asList("P_O_14", "P_B_8")));
        TransportationsDictionary.put(Transportation.METRO, new ArrayList<>(Arrays.asList("LAT", "NAT")));
    }


    public List<JourneyResponse> getJourney(JourneyRequest journeyRequest)
    {

        List<String> filteredTransportations = filterTransportations(journeyRequest);
        List<Stop> sourceAndDestinationStops = this.getSourceAndDestinationStops(this.allStops,journeyRequest.getSource(), journeyRequest.getDestination(), filteredTransportations);
        Stop sourceStop = sourceAndDestinationStops.get(0) ; Stop destinationStop = sourceAndDestinationStops.get(1);
        Map<Stop, Map<Stop, Double>> footPaths = getFootPaths(this.allStops);

        Map<Integer, Map<Stop, List<StopLabel>>> labels = mcRaptor.McRaptorAlgorithm(this.allStops, this.TripWithStopsMap ,footPaths, this.transfersDict, sourceStop, destinationStop, filteredTransportations);

        List<JourneyResponse> allJourneys = new ArrayList<>();

        for(int i = 1 ; i <= MAX_TRANSFER ; i++){
            for(StopLabel stopLabel : labels.get(i).get(destinationStop)){
                if(stopLabel.getTotalTime() != Double.MAX_VALUE){
                    JourneyResponse journeyResponse = new JourneyResponse(stopLabel.getTotalTime(), 0 , i, stopLabel.getWalkingTime());
                    journeyResponse.setSubTrips(stopLabel.getSubTrips());
                    allJourneys.add(journeyResponse);
                }
            }
        }

        if(allJourneys.isEmpty()){
            return null;
        }

        // calculate the trip points
        for (JourneyResponse journey : allJourneys)
        {
            List<double[]> points = new ArrayList<>();
            for (SubTrip subTrip : journey.getSubTrips())
            {
                if (!subTrip.getTripId().equals("Walking") && !subTrip.getTripId().equals("Transfer"))
                {
                    String firstStopId = subTrip.getStopNames().get(0).split(",")[1].trim();
                    String lastStopId = subTrip.getStopNames().get(subTrip.getStopNames().size() - 1).split(",")[1].trim();

                    double[] firstlocation = null;
                    double[] lastlocation = null;
                    //get first location
                    Stop stop1 = stopRepository.findById(firstStopId).orElse(null);
                    if(stop1 != null)
                    {
                        firstlocation = new double[] {stop1.getStopLat() , stop1.getStopLon() };
                    }
                    //get last location
                    Stop stop2 = stopRepository.findById(lastStopId).orElse(null);
                    if(stop2 != null)
                    {
                        lastlocation = new double[] {stop2.getStopLat() , stop2.getStopLon() };
                    }

                    points.addAll(getPointsBetweenLocations(subTrip.getTripId().split(",")[0].trim(), firstlocation, lastlocation));
                    journey.setJourneyPoints(points);
                }
            }
        }

        calculateThePrice(allJourneys);
        return allJourneys;
    }

    private List<double[]> getPointsBetweenLocations(String tripId, double[] firstLocation, double[] lastLocation)
    {
        List<double[]> locations = new ArrayList<>();
        List<TripPoints> pts = tripPointsRepository.findByTripId(tripId);

        // Calculate distances from firstLocation and lastLocation for all locations
        Map<double[], Double> distancesFromFirst = new HashMap<>();
        Map<double[], Double> distancesFromLast = new HashMap<>();
        for (TripPoints t : pts)
        {
            double[] location = {t.getPointLatitude(), t.getPointLongitude()};
            double distanceFromFirst = getDistance(location, firstLocation);
            double distanceFromLast = getDistance(location, lastLocation);
            distancesFromFirst.put(location, distanceFromFirst);
            distancesFromLast.put(location, distanceFromLast);
        }

        List<double[]> sortedByFirst = sortByDistance(distancesFromFirst);
        List<double[]> sortedByLast = sortByDistance(distancesFromLast);

        double[] nearestFirst = findNearestLocation(sortedByFirst);
        double[] nearestLast = findNearestLocation(sortedByLast);

        boolean foundFirst = false;
        for (TripPoints t : pts)
        {
            double latitude = t.getPointLatitude();
            double longitude = t.getPointLongitude();
            double[] location = {latitude, longitude};
            if (Arrays.equals(location, nearestFirst))
            {
                foundFirst = true;
            }
            if (Arrays.equals(location, nearestLast))
            {
                locations.add(location);
                break;
            }
            if (foundFirst)
            {
                locations.add(location);
            }
        }
        return locations;
    }
    private List<double[]> sortByDistance(Map<double[], Double> distances)
    {
        return distances.entrySet().stream()
                .sorted(Map.Entry.comparingByValue())
                .map(Map.Entry::getKey)
                .collect(Collectors.toList());
    }

    private double[] findNearestLocation(List<double[]> sortedLocations)
    {
        return sortedLocations.get(0); // Return nearest location
    }

    private double getDistance(double[] location1, double[] location2)
    {
        double lat1 = location1[0];
        double lon1 = location1[1];
        double lat2 = location2[0];
        double lon2 = location2[1];

        double dLat = Math.toRadians(lat2 - lat1);
        double dLon = Math.toRadians(lon2 - lon1);
        double a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
                Math.cos(Math.toRadians(lat1)) * Math.cos(Math.toRadians(lat2)) *
                        Math.sin(dLon / 2) * Math.sin(dLon / 2);
        double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
        return  6371 * c; // Earth radius in kilometers
    }

    private void calculateThePrice(List<JourneyResponse> allJourneys)
    {
        for(JourneyResponse journeyResponse : allJourneys)
        {
            List<SubTrip> subTrips = journeyResponse.getSubTrips();
            BigDecimal totalPrice = BigDecimal.ZERO;
            for (int i = 0; i < subTrips.size(); i++)
            {
                if (subTrips.get(i).getTripName().equals("Transfer"))
                {
                    int numberOfStops = subTrips.get(i - 1).getStopNames().size() + subTrips.get(i + 1).getStopNames().size() - 1;
                    if (numberOfStops <= 9) {
                        totalPrice = totalPrice.add(BigDecimal.valueOf(6));
                    } else if (numberOfStops <= 16) {
                        totalPrice = totalPrice.add(BigDecimal.valueOf(8));
                    } else if (numberOfStops <= 23) {
                        totalPrice = totalPrice.add(BigDecimal.valueOf(12));
                    } else {
                        totalPrice = totalPrice.add(BigDecimal.valueOf(15));
                    }
                }
                else if (subTrips.get(i).getTripName().startsWith("Metro")) {
                    if (subTrips.size() >= 3) {
                        if(i == 0){
                            if(subTrips.get(i + 1).getTripName().equals("Transfer")){
                                continue;
                            }
                            else {
                                if (subTrips.get(i).getStopNames().size() <= 9) {
                                    totalPrice = totalPrice.add(BigDecimal.valueOf(6));
                                } else if (subTrips.get(i).getStopNames().size() > 9 && subTrips.get(i).getStopNames().size() <= 16) {
                                    totalPrice = totalPrice.add(BigDecimal.valueOf(8));
                                } else if (subTrips.get(i).getStopNames().size() > 16 && subTrips.get(i).getStopNames().size() <= 23) {
                                    totalPrice = totalPrice.add(BigDecimal.valueOf(12));
                                } else {
                                    totalPrice = totalPrice.add(BigDecimal.valueOf(15));
                                }
                            }
                        }
                        else if (i == (subTrips.size() - 1)){
                            if(subTrips.get(i - 1).getTripName().equals("Transfer")){
                                continue;
                            }
                            else {
                                if (subTrips.get(i).getStopNames().size() <= 9) {
                                    totalPrice = totalPrice.add(BigDecimal.valueOf(6));
                                } else if (subTrips.get(i).getStopNames().size() > 9 && subTrips.get(i).getStopNames().size() <= 16) {
                                    totalPrice = totalPrice.add(BigDecimal.valueOf(8));
                                } else if (subTrips.get(i).getStopNames().size() > 16 && subTrips.get(i).getStopNames().size() <= 23) {
                                    totalPrice = totalPrice.add(BigDecimal.valueOf(12));
                                } else {
                                    totalPrice = totalPrice.add(BigDecimal.valueOf(15));
                                }
                            }
                        }
                        else if (!subTrips.get(i + 1).getTripName().equals("Transfer") &&  !subTrips.get(i - 1).getTripName().equals("Transfer")) {
                            if (subTrips.get(i).getStopNames().size() <= 9) {
                                totalPrice = totalPrice.add(BigDecimal.valueOf(6));
                            } else if (subTrips.get(i).getStopNames().size() > 9 && subTrips.get(i).getStopNames().size() <= 16) {
                                totalPrice = totalPrice.add(BigDecimal.valueOf(8));
                            } else if (subTrips.get(i).getStopNames().size() > 16 && subTrips.get(i).getStopNames().size() <= 23) {
                                totalPrice = totalPrice.add(BigDecimal.valueOf(12));
                            } else {
                                totalPrice = totalPrice.add(BigDecimal.valueOf(15));
                            }
                        }
                    }
                    else {
                        if (subTrips.get(i).getStopNames().size() <= 9) {
                            totalPrice = totalPrice.add(BigDecimal.valueOf(6));
                        } else if (subTrips.get(i).getStopNames().size() > 9 && subTrips.get(i).getStopNames().size() <= 16) {
                            totalPrice = totalPrice.add(BigDecimal.valueOf(8));
                        } else if (subTrips.get(i).getStopNames().size() > 16 && subTrips.get(i).getStopNames().size() <= 23) {
                            totalPrice = totalPrice.add(BigDecimal.valueOf(12));
                        } else {
                            totalPrice = totalPrice.add(BigDecimal.valueOf(15));
                        }
                    }

                }
                else if (subTrips.get(i).getTripName().startsWith("LRT")) {
                    if (subTrips.get(i).getStopNames().size() <= 4) {
                        totalPrice = totalPrice.add(BigDecimal.valueOf(10));
                    } else if (subTrips.get(i).getStopNames().size() > 4 && subTrips.get(i).getStopNames().size() <= 8) {
                        totalPrice = totalPrice.add(BigDecimal.valueOf(15));
                    } else {
                        totalPrice = totalPrice.add(BigDecimal.valueOf(20));
                    }
                }
                else {
                    if(subTrips.get(i).getTripId().equals("Walking")){
                        continue;
                    }
                    String[] words = subTrips.get(i).getTripId().split(",");
                    totalPrice = totalPrice.add(BigDecimal.valueOf(Double.parseDouble(words[1])));
                    subTrips.get(i).setTripId(words[0]);
                }
            }

            journeyResponse.setTotalPrice(totalPrice.doubleValue());

        }
    }


    private List<Stop> getSourceAndDestinationStops(List<Stop> filteredStops, Location sourceLocation, Location destinationLocation, List<String> filteredTransportations)
    {

        double minDistance1 = Double.MAX_VALUE; double minDistance2 = Double.MAX_VALUE;

        double minDistanceForSource; double minDistanceForDestination;

        Stop sourceStop = null ; Stop destinationStop = null;

        for (Stop s : filteredStops) {
            minDistanceForSource = DistanceFromStop.getMinDistance(sourceLocation.getLatitude(), sourceLocation.getLongitude(), s.getStopLat(), s.getStopLon());
            if (minDistanceForSource < minDistance1) {
                for(StopTimes stopTimes : s.getStopTimes()){
                    if(filteredTransportations.contains(stopTimes.getTrip().getRoute().getAgency().getAgencyId())) {
                        sourceStop = s;
                        minDistance1 = minDistanceForSource;
                        break;
                    }
                }
            }
            minDistanceForDestination = DistanceFromStop.getMinDistance(destinationLocation.getLatitude(), destinationLocation.getLongitude(), s.getStopLat(), s.getStopLon());
            if (minDistanceForDestination < minDistance2) {
                for(StopTimes stopTimes : s.getStopTimes()){
                    if(filteredTransportations.contains(stopTimes.getTrip().getRoute().getAgency().getAgencyId())) {
                        destinationStop = s;
                        minDistance2 = minDistanceForDestination;
                        break;
                    }
                }
            }
        }

        assert sourceStop != null;
        assert destinationStop != null;
        return List.of(sourceStop, destinationStop);

    }

    private List<String> filterTransportations(JourneyRequest journeyRequest)
    {
        // remove metro from transportation if time between 12:00 am and 05:00 am
        if (journeyRequest.getTime().isAfter(LocalTime.of(0, 0)) && journeyRequest.getTime().isBefore(LocalTime.of(5, 0))) {
            journeyRequest.getTransportations().remove(Transportation.METRO);
        }

        List<String> transportationsList = new ArrayList<>();
        for(Transportation trans : journeyRequest.getTransportations())
        {
            transportationsList.addAll(TransportationsDictionary.get(trans));
        }

        return transportationsList;
    }

    private String getTransType(String agencyId, List<String> busIds, List<String> metroIds, List<String> lrtIds)
    {
        if (busIds.contains(agencyId))
        {
            if (agencyId.equals("P_O_14"))
            {
                return "microbus";
            }
            else
            {
                return "bus";
            }
        }
        else if (metroIds.contains(agencyId))
        {
            return "metro";
        }
        else if (lrtIds.contains(agencyId))
        {
            return "lrt";
        }
        else
        {
            return agencyId;
        }
    }

    private Map<String, List<StopTimes>> getTripWithStopsMap(){
        List<Trip> allTrips = tripRepository.findAllWithStopTimes();
        Map<String, List<StopTimes>> tripsDict = new HashMap<>();
        for(Trip trip : allTrips){
            tripsDict.put(trip.getTripId(), trip.getStopTimes());
        }
        return tripsDict;
    }

    private Map<Stop, Map<Stop, Double>> getFootPaths(List<Stop> filteredStops)
    {
        List<String> busIds = Arrays.asList("AGY", "BOX", "CTA", "COOP", "CTA_M", "GRN", "P_B_8");
        List<String> metroIds = Collections.singletonList("LAT");
        List<String> lrtIds = Collections.singletonList("NAT");
        Map<Stop, Map<Stop, Double>> footPaths = new HashMap<>();

        for (Stop stop1 : filteredStops)
        {
            String agencyType1 = getTransType(stop1.getStopTimes().get(0).getTrip().getRoute().getAgency().getAgencyId(), busIds, metroIds, lrtIds);

            for (Stop stop2 : filteredStops)
            {
                String agencyType2 = getTransType(stop2.getStopTimes().get(0).getTrip().getRoute().getAgency().getAgencyId(), busIds, metroIds, lrtIds);

                if (!agencyType1.equals(agencyType2))
                {
                    double distanceInMeters = DistanceFromStop.calculateDistance(
                            stop1.getStopLat(), stop1.getStopLon(),
                            stop2.getStopLat(), stop2.getStopLon());

                    //BUS --- METRO
                    if ((agencyType1.equals("bus") && agencyType2.equals("metro")) || (agencyType1.equals("metro") && agencyType2.equals("bus")))
                    {
                        if (distanceInMeters < 500)
                        {
                            if(footPaths.get(stop1) == null)
                            {
                                footPaths.put(stop1, new HashMap<>());
                            }
                            footPaths.get(stop1).put(stop2, Math.ceil(distanceInMeters / 1.5 / 60));
                        }
                    }
                    //BUS --- LRT
                    else if ((agencyType1.equals("bus") && agencyType2.equals("lrt")) || (agencyType1.equals("lrt") && agencyType2.equals("bus")))
                    {
                        if (distanceInMeters < 500) {
                            if(footPaths.get(stop1) == null){
                                footPaths.put(stop1, new HashMap<>());
                            }
                            footPaths.get(stop1).put(stop2, Math.ceil(distanceInMeters / 1.5 / 60));
                        }
                    }
                    //MICROBUS --- METRO
                    if ((agencyType1.equals("microbus") && agencyType2.equals("metro")) || (agencyType1.equals("metro") && agencyType2.equals("microbus")))
                    {
                        if (distanceInMeters < 500) {
                            if(footPaths.get(stop1) == null){
                                footPaths.put(stop1, new HashMap<>());
                            }
                            footPaths.get(stop1).put(stop2, Math.ceil(distanceInMeters / 1.5 / 60));
                        }
                    }
                    //MICROBUS --- LRT
                    else if ((agencyType1.equals("microbus") && agencyType2.equals("lrt")) || (agencyType1.equals("lrt") && agencyType2.equals("microbus")))
                    {
                        if (distanceInMeters < 500) {
                            if(footPaths.get(stop1) == null){
                                footPaths.put(stop1, new HashMap<>());
                            }
                            footPaths.get(stop1).put(stop2, Math.ceil(distanceInMeters / 1.5 / 60));
                        }
                    }

                    //METRO --- LRT
                    else if ((agencyType1.equals("lrt") && agencyType2.equals("metro")) || (agencyType1.equals("metro") && agencyType2.equals("lrt")))
                    {
                        if (distanceInMeters < 500)
                        {
                            if(footPaths.get(stop1) == null){
                                footPaths.put(stop1, new HashMap<>());
                            }
                            footPaths.get(stop1).put(stop2, Math.ceil(distanceInMeters / 1.5 / 60));
                        }
                    }
                }
            }
        }
        return footPaths;
    }

    private Map<Stop, Map<Stop, Double>> getTrsanfers(List<Transfer> transferList)
    {
        Map<Stop, Map<Stop, Double>> transfersDict = new HashMap<>();

        for(Transfer transfer : transferList){
            if(transfersDict.get(transfer.getTransferStops().get(0).getTransferStop()) == null){
                transfersDict.put(transfer.getTransferStops().get(0).getTransferStop(), new HashMap<>());
            }
            transfersDict.get(transfer.getTransferStops().get(0).getTransferStop()).put(transfer.getTransferStops().get(1).getTransferStop(), 2.0);
        }

        return transfersDict;
    }

}