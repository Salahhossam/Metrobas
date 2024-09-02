package com.transportation.metrobas.user;

import org.springframework.stereotype.Service;

@Service
public class UserAdabter {

    public UserDto UserToDto(User user){
        return new UserDto(
                user.getUserId(),
                user.getEmail(),
                user.getPhone(),
                user.getUserName(),
                user.getAge(),
                user.getGender()
        );
    }
}
