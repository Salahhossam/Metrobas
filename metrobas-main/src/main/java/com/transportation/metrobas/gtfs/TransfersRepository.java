package com.transportation.metrobas.gtfs;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface TransfersRepository extends JpaRepository<Transfer, Integer> {

    @Query("SELECT t FROM Transfer t LEFT JOIN FETCH t.transferStops")
    List<Transfer> findAllWithTransferStops();
}
