package com.transportation.metrobas.gtfs;

import jakarta.persistence.*;

import java.util.Objects;

@Entity
@Table(name = "transfers_stops")
public class TransferStops {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "transfers_stop_id")
    private int transferStopId;

    @Column(name = "sequence")
    private int sequence;

    @ManyToOne(cascade= {CascadeType.PERSIST, CascadeType.MERGE ,CascadeType.DETACH, CascadeType.REFRESH})
    @JoinColumn(name = "stop_id")
    private Stop transferStop;

    @ManyToOne(cascade= {CascadeType.PERSIST, CascadeType.MERGE ,CascadeType.DETACH, CascadeType.REFRESH})
    @JoinColumn(name = "transfer_id")
    private Transfer transfer;

    public Stop getTransferStop() {
        return transferStop;
    }

    public void setTransferStop(Stop transferStop) {
        this.transferStop = transferStop;
    }

    public Transfer getTransfer() {
        return transfer;
    }

    public void setTransfer(Transfer transfer) {
        this.transfer = transfer;
    }

    public TransferStops() {
    }

    public TransferStops(int sequence) {
        this.sequence = sequence;
    }

    public int getTransferStopId() {
        return transferStopId;
    }

    public void setTransferStopId(int transferStopId) {
        this.transferStopId = transferStopId;
    }

    public int getSequence() {
        return sequence;
    }

    public void setSequence(int sequence) {
        this.sequence = sequence;
    }

    @Override
    public String toString() {
        return "TransferStops{" +
                "transferStopId=" + transferStopId +
                ", sequence=" + sequence +
                '}';
    }


    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        TransferStops that = (TransferStops) o;
        return transferStopId == that.transferStopId;
    }

    @Override
    public int hashCode() {
        return Objects.hash(transferStopId);
    }
}
