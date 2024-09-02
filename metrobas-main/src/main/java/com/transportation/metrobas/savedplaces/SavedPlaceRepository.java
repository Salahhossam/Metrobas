package com.transportation.metrobas.savedplaces;

import jakarta.persistence.criteria.CriteriaBuilder;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface SavedPlaceRepository extends JpaRepository<SavedPlace,Integer> {

    @Query("SELECT sp FROM SavedPlace sp WHERE user.userId=:userId")
    List<SavedPlace> findSavedPlacesByUserId(int userId);
}
