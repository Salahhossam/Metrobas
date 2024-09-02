package com.transportation.metrobas.gtfs;

import jakarta.persistence.*;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;
import java.util.Objects;

@Entity
@Table(name = "transfers")
public class Transfer {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "transfer_id")
    private int transferId;

    @Column(name = "min_transfer_time")
    private double minTransferTime;

    @OneToMany(mappedBy = "transfer" , cascade = CascadeType.ALL, fetch = FetchType.EAGER)
    private List<TransferStops> transferStops;

    public Transfer() {
    }

    public Transfer(double minTransferTime) {
        this.minTransferTime = minTransferTime;
    }

    public int getTransferId() {
        return transferId;
    }

    public void setTransferId(int transferId) {
        this.transferId = transferId;
    }

    public double getMinTransferTime() {
        return minTransferTime;
    }

    public void setMinTransferTime(double minTransferTime) {
        this.minTransferTime = minTransferTime;
    }

    public List<TransferStops> getTransferStops() {
        return transferStops;
    }

    public void setTransferStops(List<TransferStops> transferStops) {
        this.transferStops = transferStops;
    }

    public void addTransferStop(TransferStops transferStop){
        if(this.transferStops == null){
            this.transferStops = new ArrayList<>();
        }
        this.transferStops.add(transferStop);
    }
    @Override
    public String toString() {
        return "Transfer{" +
                "transferId=" + transferId +
                ", minTransferTime=" + minTransferTime +
                '}';
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        Transfer transfer = (Transfer) o;
        return transferId == transfer.transferId;
    }

    @Override
    public int hashCode() {
        return Objects.hash(transferId);
    }
}
