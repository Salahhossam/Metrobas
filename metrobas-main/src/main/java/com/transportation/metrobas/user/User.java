package com.transportation.metrobas.user;

import com.fasterxml.jackson.annotation.JsonManagedReference;
import com.transportation.metrobas.chat.Message;
import com.transportation.metrobas.chat.MessageReports;
import com.transportation.metrobas.enums.Role;
import com.transportation.metrobas.enums.Gender;
import com.transportation.metrobas.report.Report;
import com.transportation.metrobas.savedplaces.SavedPlace;
import jakarta.persistence.*;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;

import java.util.ArrayList;
import java.util.Collection;
import java.util.List;

@Entity
@Table(name = "users")
public class User implements UserDetails{
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "user_id")
    private int userId;

    @Column(name = "first_name")
    private String firstName;

    @Column(name = "last_name")
    private String lastName;

    @Column(name = "email")
    private String email;

    @Column(name = "password")
    private String password;

    @Column(name = "phone")
    private String phone;

    @Column(name = "user_name")
    private String userName;

    @Column(name = "role")
    @Enumerated(EnumType.STRING)
    private Role role;

    @Column(name = "age")
    private int age;

    @Enumerated(EnumType.STRING)
    @Column(name = "gender")
    private Gender gender;

    @Column(name = "is_enabled")
    private boolean isEnabled;

    @OneToMany(mappedBy = "user", cascade = CascadeType.ALL)
    private List<SavedPlace> savedPlaces;

    @OneToMany(mappedBy = "user", cascade = CascadeType.ALL)
    private List<Report> reports;

    @OneToMany(mappedBy = "user", cascade = CascadeType.ALL)
    private List<Message> messages;


    @OneToMany(mappedBy = "user", cascade = CascadeType.ALL)
    private List<MessageReports> messageReports;

    public User() {
    }


    public User(String firstName, String lastName, String email, String password, String phone, String userName, Role role, int age, Gender gender) {
        this.firstName = firstName;
        this.lastName = lastName;
        this.email = email;
        this.password = password;
        this.phone = phone;
        this.userName = userName;
        this.role = role;
        this.age = age;
        this.gender = gender;
    }

    public List<SavedPlace> getSavedPlaces() {
        return savedPlaces;
    }

    public void setSavedPlaces(List<SavedPlace> savedPlaces) {
        this.savedPlaces = savedPlaces;
    }

    public void addSavedPlace(SavedPlace preference){
        if(this.savedPlaces == null){
            this.savedPlaces = new ArrayList<>();
        }
        this.savedPlaces.add(preference);
    }

    public List<Report> getReports() {
        return reports;
    }

    public void setReports(List<Report> reports) {
        this.reports = reports;
    }

    public void addReport(Report report){
        if(this.reports == null){
            this.reports = new ArrayList<>();
        }
        this.reports.add(report);
    }

    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        return List.of(new SimpleGrantedAuthority(this.role.name()));
    }

    @Override
    public String getPassword() {
        return this.password;
    }

    @Override
    public String getUsername() {
        return this.userName;
    }

    @Override
    public boolean isAccountNonExpired() {
        return true;
    }

    @Override
    public boolean isAccountNonLocked() {
        return true;
    }

    @Override
    public boolean isCredentialsNonExpired() {
        return true;
    }

    @Override
    public boolean isEnabled() {
        return isEnabled;
    }

    public int getUserId() {
        return userId;
    }

    public void setEnabled(boolean enabled) {
        isEnabled = enabled;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public String getFirstName() {
        return firstName;
    }

    public void setFirstName(String firstName) {
        this.firstName = firstName;
    }

    public String getLastName() {
        return lastName;
    }

    public void setLastName(String lastName) {
        this.lastName = lastName;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public String getUserName() {
        return userName;
    }

    public void setUserName(String userName) {
        this.userName = userName;
    }

    public Role getRole() {
        return role;
    }

    public void setRole(Role role) {
        this.role = role;
    }

    public int getAge() {
        return age;
    }

    public void setAge(int age) {
        this.age = age;
    }


    public Gender getGender() {
        return gender;
    }

    public void setGender(Gender gender) {
        this.gender = gender;
    }

    public List<Message> getMessages() {
        return messages;
    }

    public void setMessages(List<Message> messages) {
        this.messages = messages;
    }

    public List<MessageReports> getMessageReports() {
        return messageReports;
    }

    public void setMessageReports(List<MessageReports> messageReports) {
        this.messageReports = messageReports;
    }
}
