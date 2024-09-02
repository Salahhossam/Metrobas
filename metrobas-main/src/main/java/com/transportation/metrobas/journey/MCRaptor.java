package com.transportation.metrobas.journey;

import com.transportation.metrobas.gtfs.*;
import org.springframework.stereotype.Service;
import java.time.Duration;
import java.util.*;

@Service
public class MCRaptor {

    private final int MAX_TRANSFER = 4;


    public Map<Integer, Map<Stop, List<StopLabel>>> McRaptorAlgorithm(List<Stop> allStops, Map<String, List<StopTimes>> tripWithStopsMap ,Map<Stop, Map<Stop, Double>> footPaths, Map<Stop, Map<Stop, Double>> transfers, Stop sourceStop, Stop destinationStop, List<String> filteredTransportations){

        // initialize mc raptor algorithm
        Map<Integer, Map<Stop, List<StopLabel>>> labels = new HashMap<>();
        Map<String, Stop> stopsDict = new HashMap<>();
        Map<Stop, List<StopLabel>> starLabels = new HashMap<>();
        Queue<Stop> markedStopsQueue = new LinkedList<>();
        this.initializeMcraptor(labels, starLabels, markedStopsQueue, allStops, sourceStop, stopsDict);

        // main code
        for(int i = 1 ; i <= MAX_TRANSFER ; i++){
            Map<Trip, StopTimes> tripsWithStops = new HashMap<>();
            while (!markedStopsQueue.isEmpty()) {
                Stop markedStop = markedStopsQueue.poll();
                // loop for all trips that pass within this stop
                for (StopTimes stopTime : markedStop.getStopTimes()) {
                    Trip currentTrip = stopTime.getTrip();
                    if (tripsWithStops.containsKey(currentTrip)) {
                        if (stopTime.getStopSequence() < tripsWithStops.get(stopTime.getTrip()).getStopSequence()) {
                            tripsWithStops.put(currentTrip, stopTime);
                        }
                    } else {
                        tripsWithStops.put(currentTrip, stopTime);
                    }
                }
            }

            List<StopLabel> br;
            List<StopTimes> stopTimesListInTrip;
            for(Trip trip : tripsWithStops.keySet()){
                if(!filteredTransportations.contains(trip.getRoute().getAgency().getAgencyId())){
                    continue;
                }
                br = new ArrayList<>();
                stopTimesListInTrip = tripWithStopsMap.get(trip.getTripId()).subList(tripsWithStops.get(trip).getStopSequence() - 1, tripWithStopsMap.get(trip.getTripId()).size());
                for(int stopTimeCount = 0 ; stopTimeCount < stopTimesListInTrip.size(); stopTimeCount++){

                    Stop stopInTrip = stopTimesListInTrip.get(stopTimeCount).getStop();

                    // first step
                    for(StopLabel label : br){
                        label.setTotalTime(label.getTotalTime() + Duration.between(stopTimesListInTrip.get(stopTimeCount - 1).getArriveTime(), stopTimesListInTrip.get(stopTimeCount).getArriveTime()).toMinutes());
                        if(label.getSubTrips() == null){
                            label.addSubTrip(new SubTrip());
                            if(trip.getRoute().getRent() != null){
                                label.getSubTrips().get(label.getSubTrips().size() - 1).setTripId(trip.getTripId() + "," + trip.getRoute().getRent());
                            }
                            else {
                                label.getSubTrips().get(label.getSubTrips().size() - 1).setTripId(trip.getTripId());
                            }
                            label.getSubTrips().get(label.getSubTrips().size() - 1).setTripName(trip.getRoute().getRouteShortName() + trip.getTripHeadsign());
                            label.getSubTrips().get(label.getSubTrips().size() - 1).addStopName(stopTimesListInTrip.get(stopTimeCount - 1).getStop().getStopName() + " , " + stopTimesListInTrip.get(stopTimeCount - 1).getStop().getStopId());
                        }
                        else if(!trip.getTripId().equals(label.getSubTrips().get(label.getSubTrips().size() - 1).getTripId().split(",")[0])){
                            label.addSubTrip(new SubTrip());
                            if(trip.getRoute().getRent() != null){
                                label.getSubTrips().get(label.getSubTrips().size() - 1).setTripId(trip.getTripId() + "," + trip.getRoute().getRent());
                            }
                            else {
                                label.getSubTrips().get(label.getSubTrips().size() - 1).setTripId(trip.getTripId());
                            }
                            label.getSubTrips().get(label.getSubTrips().size() - 1).setTripName(trip.getRoute().getRouteShortName() + trip.getTripHeadsign());
                            label.getSubTrips().get(label.getSubTrips().size() - 1).addStopName(stopTimesListInTrip.get(stopTimeCount - 1).getStop().getStopName() + " , " + stopTimesListInTrip.get(stopTimeCount - 1).getStop().getStopId());
                        }
                        label.getSubTrips().get(label.getSubTrips().size() - 1).addStopName(stopInTrip.getStopName() + " , " + stopInTrip.getStopId());
                    }

                    // second step
                    List<StopLabel> bkp = labels.get(i).get(stopInTrip);
                    List<StopLabel> brNew = new ArrayList<>();
                    for(StopLabel lr : br){
                        if(checkNonDominance(lr, starLabels.get(stopInTrip)) && checkNonDominance(lr, starLabels.get(destinationStop))){
                            brNew.add(lr);
                            List<StopLabel> stopLabelsNonDominated = new ArrayList<>();
                            stopLabelsNonDominated.add(lr);
                            stopLabelsNonDominated.addAll(starLabels.get(stopInTrip));
                            starLabels.put(stopInTrip, giveNonDominatingLabels(stopLabelsNonDominated));
                        }
                    }


                    List<List<StopLabel>> bags = merge(bkp, brNew);

                    labels.get(i).put(stopInTrip, bags.get(2));

                    if(!getNewLables(bags.get(0), bags.get(1), bags.get(2)).isEmpty()){
                        markedStopsQueue.add(stopsDict.get(stopInTrip.getStopId()));
                    }

                    // third step
                    List<StopLabel> Bk1p = getCopyOfStopLabels(labels.get(i-1).get(stopInTrip));

                    List<List<StopLabel>> bags2 = merge(br, Bk1p);

                    br = getCopyOfStopLabels(bags2.get(2));

                }

            }

            Queue<Stop> markedStopsQueueCopy = new LinkedList<>(markedStopsQueue);
            for(Stop markedStop : markedStopsQueueCopy){
                if(footPaths.containsKey(markedStop)){
                    for(Map.Entry<Stop, Double> entry : footPaths.get(markedStop).entrySet()){
                        List<StopLabel> tembBag = this.getCopyOfStopLabels(labels.get(i).get(markedStop));
                        for(StopLabel s : tembBag){
                            if(s.getSubTrips() == null){
                                s.addSubTrip(new SubTrip());
                                s.getSubTrips().get(s.getSubTrips().size() - 1).setTripId("Walking");
                                s.getSubTrips().get(s.getSubTrips().size() - 1).setTripName("Walking");
                                s.getSubTrips().get(s.getSubTrips().size() - 1).addStopName(markedStop.getStopName());
                            }
                            else if(!"Walking".equals(s.getSubTrips().get(s.getSubTrips().size() - 1).getTripId())){
                                s.addSubTrip(new SubTrip());
                                s.getSubTrips().get(s.getSubTrips().size() - 1).setTripId("Walking");
                                s.getSubTrips().get(s.getSubTrips().size() - 1).setTripName("Walking");
                                s.getSubTrips().get(s.getSubTrips().size() - 1).addStopName(markedStop.getStopName());
                            }
                            s.getSubTrips().get(s.getSubTrips().size() - 1).addStopName(entry.getKey().getStopName());
                            s.setTotalTime(s.getTotalTime() + entry.getValue());
                            s.setWalkingTime(s.getWalkingTime() + entry.getValue());
                        }
                        List<StopLabel> bkpj = labels.get(i).get(entry.getKey());
                        List<List<StopLabel>> bags3 = merge(bkpj, tembBag);
                        labels.get(i).put(entry.getKey(), bags3.get(2));
                        List<StopLabel> newLabels = getNewLables(bags3.get(0), bags3.get(1), bags3.get(2));
                        tembBag.addAll(starLabels.get(entry.getKey()));
                        starLabels.put(entry.getKey(), giveNonDominatingLabels(tembBag));
                        if(!newLabels.isEmpty()){
                            markedStopsQueue.add(stopsDict.get(entry.getKey().getStopId()));
                        }
                    }
                }
                if (transfers.containsKey(markedStop)) {
                    for(Map.Entry<Stop, Double> entry : transfers.get(markedStop).entrySet()){
                        List<StopLabel> tembBag2 = this.getCopyOfStopLabels(labels.get(i).get(markedStop));
                        for(StopLabel s : tembBag2){
                            if(s.getSubTrips() == null){
                                s.addSubTrip(new SubTrip());
                                s.getSubTrips().get(s.getSubTrips().size() - 1).setTripId("Transfer");
                                s.getSubTrips().get(s.getSubTrips().size() - 1).setTripName("Transfer");
                                s.getSubTrips().get(s.getSubTrips().size() - 1).addStopName(markedStop.getStopName());
                            }
                            else if(!"Transfer".equals(s.getSubTrips().get(s.getSubTrips().size() - 1).getTripId())){
                                s.addSubTrip(new SubTrip());
                                s.getSubTrips().get(s.getSubTrips().size() - 1).setTripId("Transfer");
                                s.getSubTrips().get(s.getSubTrips().size() - 1).setTripName("Transfer");
                                s.getSubTrips().get(s.getSubTrips().size() - 1).addStopName(markedStop.getStopName());
                            }
                            s.getSubTrips().get(s.getSubTrips().size() - 1).addStopName(entry.getKey().getStopName());
                            s.setTotalTime(s.getTotalTime() + entry.getValue());
                            s.setWalkingTime(s.getWalkingTime() + entry.getValue());
                        }
                        List<StopLabel> bkpj2 = labels.get(i).get(entry.getKey());
                        List<List<StopLabel>> bags4 = merge(bkpj2, tembBag2);
                        labels.get(i).put(entry.getKey(), bags4.get(2));
                        List<StopLabel> newLabels = getNewLables(bags4.get(0), bags4.get(1), bags4.get(2));
                        tembBag2.addAll(starLabels.get(entry.getKey()));
                        starLabels.put(entry.getKey(), giveNonDominatingLabels(tembBag2));
                        if(!newLabels.isEmpty()){
                            markedStopsQueue.add(stopsDict.get(entry.getKey().getStopId()));
                        }
                    }
                }

            }

            if(markedStopsQueue.isEmpty()){
                break;
            }

        }

        return labels;
    }

    private List<StopLabel> getCopyOfStopLabels(List<StopLabel> stopLabelList)
    {
        List<StopLabel> stopLabelListCopy = new ArrayList<>();
        for(StopLabel stopLabel : stopLabelList){
            StopLabel s = stopLabel.copy();
            stopLabelListCopy.add(s);
        }
        return stopLabelListCopy;
    }

    private List<List<StopLabel>> merge(List<StopLabel> existingBag, List<StopLabel> newBag)
    {

        List<StopLabel> existingBagWithoutDuplicates = removeDuplicates(existingBag);

        List<StopLabel> newBagWithoutDuplicates = removeDuplicates(newBag);

        List<StopLabel> extendedBag = new ArrayList<>();
        extendedBag.addAll(existingBagWithoutDuplicates);
        extendedBag.addAll(newBagWithoutDuplicates);

        List<StopLabel> mergedBag = paretoSet(removeDuplicates(extendedBag));

        List<StopLabel> meredBaWithoutDuplicates = removeDuplicates(mergedBag);

        List<List<StopLabel>> bags = new ArrayList<>();

        bags.add(existingBagWithoutDuplicates);
        bags.add(newBagWithoutDuplicates);
        bags.add(meredBaWithoutDuplicates);

        return bags;
    }

    private List<StopLabel>  getNewLables(List<StopLabel> existingBagWithoutDuplicates, List<StopLabel> newBagWithoutDuplicates, List<StopLabel> meredBaWithoutDuplicates)
    {
        List<StopLabel> newlyAddedLabels = new ArrayList<>();
        for(StopLabel stopLabel : newBagWithoutDuplicates){
            if(meredBaWithoutDuplicates.contains(stopLabel) && !existingBagWithoutDuplicates.contains(stopLabel)){
                newlyAddedLabels.add(stopLabel);
            }
        }
        return newlyAddedLabels;
    }

    private List<StopLabel> giveNonDominatingLabels(List<StopLabel> stopLabelList)
    {
        return paretoSet(removeDuplicates(stopLabelList));
    }

    private List<StopLabel> removeDuplicates(List<StopLabel> stopLabelList)
    {
        List<StopLabel> listWithDuplicates = new ArrayList<>();
        for (StopLabel label : stopLabelList) {
            if (!listWithDuplicates.contains(label)) {
                listWithDuplicates.add(label);
            }
        }
        return listWithDuplicates;
    }


    private boolean checkNonDominance(StopLabel stopLabel, List<StopLabel> stopLabelList)
    {

        List<StopLabel> allList = new ArrayList<>();
        allList.add(stopLabel);
        allList.addAll(stopLabelList);

        List<StopLabel> nonDominatingLabels = paretoSet(allList);

        return nonDominatingLabels.contains(stopLabel) && !stopLabelList.contains(stopLabel);
    }

    private List<StopLabel> paretoSet(List<StopLabel> stopLabels)
    {

        List<StopLabel> nonDominated = new ArrayList<>();

        for (StopLabel label : stopLabels) {
            boolean isDominated = false;
            List<StopLabel> toRemove = new ArrayList<>();

            for (StopLabel nd : nonDominated) {
                if (dominates(nd, label)) {
                    isDominated = true;
                    break;
                } else if (dominates(label, nd)) {
                    toRemove.add(nd);
                }
            }

            // Remove dominated labels
            nonDominated.removeAll(toRemove);

            if (!isDominated) {
                nonDominated.add(label);
            }
        }
        return nonDominated;
    }

    private boolean dominates(StopLabel a, StopLabel b)
    {
        return (a.getTotalTime() <= b.getTotalTime()) && (a.getWalkingTime() <= b.getWalkingTime());
    }

    private void initializeMcraptor(Map<Integer, Map<Stop, List<StopLabel>>> labels , Map<Stop, List<StopLabel>> starLabels  , Queue<Stop> queue ,List<Stop> stops, Stop stopSource,  Map<String, Stop> stopsDict)
    {

        for (int i = 0; i <= MAX_TRANSFER; i++) {
            labels.put(i, new HashMap<>());
            for (Stop stop : stops) {
                labels.get(i).put(stop, new ArrayList<>());
                labels.get(i).get(stop).add(new StopLabel(Double.MAX_VALUE, Double.MAX_VALUE));
            }
        }

        labels.get(0).put(stopSource, new ArrayList<>());
        labels.get(0).get(stopSource).add(new StopLabel(0, 0));

        for (Stop stop : stops) {
            starLabels.put(stop, new ArrayList<>());
            starLabels.get(stop).add(new StopLabel(Double.MAX_VALUE, Double.MAX_VALUE));
            stopsDict.put(stop.getStopId(), stop);
        }

        starLabels.put(stopSource, new ArrayList<>());
        starLabels.get(stopSource).add(new StopLabel(0, 0));

        queue.add(stopsDict.get(stopSource.getStopId()));

    }
}
