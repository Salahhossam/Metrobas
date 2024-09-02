package com.transportation.metrobas.gtfs;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface StopTimesRepository extends JpaRepository<StopTimes, Integer> {

}
