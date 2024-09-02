package com.transportation.metrobas.user;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface UserRepository extends JpaRepository<User, Integer> {
    Optional<User> findByUserNameOrEmail(String userName, String email);

    Optional<User> findByUserName(String userName);

}
