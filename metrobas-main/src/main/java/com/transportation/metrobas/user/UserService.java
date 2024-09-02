package com.transportation.metrobas.user;

import com.transportation.metrobas.exception.EmailAlreadyExist;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
public class UserService implements UserDetailsService {

    private final UserRepository userRepository;

    @Autowired
    public UserService(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    @Override
    public UserDetails loadUserByUsername(String userName) throws UsernameNotFoundException {
        return this.userRepository.findByUserNameOrEmail(userName, userName)
                .orElseThrow(() -> new UsernameNotFoundException("user name or email is not found"));
    }

    public List<User> findAllUsers(){
        return this.userRepository.findAll();
    }

    public User findUserById(int userId){
        return this.userRepository.findById(userId).orElseThrow();
    }

    @Transactional
    public void updateUserNameOfUser(int userId,  String userName){
        if(this.userRepository.findByUserName(userName).isPresent()){
            throw new EmailAlreadyExist("user name is already exist");
        }
        User user = this.userRepository.findById(userId).orElseThrow();
        user.setUserName(userName);
        this.userRepository.save(user);
    }
}
