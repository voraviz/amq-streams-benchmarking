package org.acme.song.app;

import java.util.concurrent.CompletableFuture;
import java.util.concurrent.CompletionStage;

import javax.inject.Inject;
import javax.json.bind.JsonbBuilder;
import javax.ws.rs.Consumes;
import javax.ws.rs.POST;
import javax.ws.rs.Path;
import javax.ws.rs.core.MediaType;

import org.eclipse.microprofile.metrics.MetricUnits;
import org.eclipse.microprofile.metrics.annotation.Counted;
import org.eclipse.microprofile.metrics.annotation.Timed;
import org.eclipse.microprofile.reactive.messaging.Channel;
import org.eclipse.microprofile.reactive.messaging.Emitter;
import org.eclipse.microprofile.reactive.messaging.OnOverflow;

import io.smallrye.reactive.messaging.kafka.KafkaRecord;


@Path("/")
public class SongResource {
    
    @Inject
    @Channel("songs")
    @OnOverflow(value = OnOverflow.Strategy.BUFFER, bufferSize = 1024)
    Emitter<String> songs;

    @POST
    @Path("/songs")
    @Consumes(MediaType.APPLICATION_JSON)
    @Counted(
        name = "countdSong", 
        description = "Counts how many times the song producer method has been invoked"
        )
    @Timed(
        name = "timedSong", 
        description = "Times how long it takes to put message to topic", 
        unit = MetricUnits.MILLISECONDS
        )
    public CompletionStage<Void> createSong(Song song) {
        song.setOp(song.getOp());
        //song.setOp(Operation.ADD);
        System.out.println(song);
        KafkaRecord<Integer, String> msg = KafkaRecord.of(song.id, JsonbBuilder.create().toJson(song));
        songs.send(msg);
        return CompletableFuture.completedFuture(null);
    }

}