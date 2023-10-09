// This has the feature that the frequency ratio between two successive (chromatic) notes is 2^(1/12) approximately 1.05946309435
// That’s because the relationship between pitch perception and frequency is logarithmic
//
// frequency_range = 2 / sampling_rate
//
// 20 Hz to 20,000 Hz is the commonly referenced audio frequency range.
// However, the average human can hear less than this 20 Hz to 20 kHz range
//
// a standard sample rate for music is 44.1 kHz or 44,100 samples per second.
// This is the standard for most consumer audio,
//
// Nyquist's theorem states that the sample rate must be two times the highest frequency we want to record.
// Since the highest frequency we can hear is 20kHz, our sample rate should be above 40kHz
// if we want to record that sound as accurately as possible with little distortion
// and avoid aliasing (more on aliasing later)
//
// Cutting the speed of a recording in half would.
// Double its duration.
// Lower the pitch (we would not hear the halfing of the pitch because our perception of pitch is logarithmic as defined in the code)
// doubling the duration lowers the pitch of each note by an octave. An octane lower is half the frequency
// Lower the sample rate in half
// so if we want to change the pitch and keep the duration the same we would have to add or remove some samples (according to the formula in the code).
// this is also because 200 Hz to 400 Hz is exactly an octave- the frequency ratio is exactly two,
// but 2000 Hz and 2200 are much less than an octave apart- the ratio is much less than two.
// So what happens the in the code is that it adds some samples in a certain way, but keeps the time the same by setting the new higher sample rate
//
//
// The right bitrate for a file depends on what you want to use that file for and the means of delivering the audio.
// In general, a high bitrate means high-quality audio, provided the sample rate and bit depth are also high.
// More information, in a very general sense, means better sound quality.
// Audio CD bitrate is always 1,411 kilobits per second (Kbps).
// The MP3 format can range from around 96 to 320Kbps and streaming services like Spotify range from around 96 to 160Kbps.
// High bitrates appeal to audiophiles, but they are not always better.
// Keep in mind how your digital audio is going to have to contend with bottlenecks.
// If listeners will be downloading it or listening to it on physical audio formats, you can afford a high bitrate.
// If they’re streaming it, you likely want the bitrate to be a bit lower so it can be streamed effectively.
// However, below about 90Kbps the human ear will notice a significant drop in quality, even without training.
//
// A high sample rate and a higher bit depth both increase the amount of information in an audio file
// and likewise increase the file size
//
//
// sampleRate, data = wav.file.read("./some_file.wav")
// samples = data.shape[0]
//
// keyChange = 2
//
// newRate = 0
// newData = np.array([])
// factor = 1 / ((1.06**keyChange) - 1)
// if keyChange > 0:
//     for i in range(samples):
//         if i % factor == 0:
//             np.insert(data, i, data[i])
//     newData = data
//     newRate = math.floor(sampleRate * (1.06**keyChange))
// else:
//     newData = []
//     for i in range(samples):
//         if not i % factor == 0:
//             newData.append(data[i])
//     newRate = math.floor(sampleRate / (1.06**keyChange))
//     newData = np.array(newData)
//
//
// https://pressbooks.pub/sound/chapter/pitch-and-frequency-in-music/
//
// also change the speed without changing the pitch
// how would I change the pitch of the song by one octave and not one key(do this too)

const std = @import("std");

// find the genneral .wav format, I want to makke out how each section is represented into the file
// how does AUDACITY for example makes it into bits and knows how to play a .wav
// What does .wav file look like inside, Read it and also geet its info (birate etc)
// see the article for the .wav tto learn about thee info,
// the song(numbers) come after "data" printed from the const file
// Create a wav.zig

// I DONT THINK I NEED THIS ONE TO BE GENERIC
// I NEED TO ALOCATE MEMORY AFTER I FIND THE SIZE OF THE FILE
// AT FIRST I COULD ONLY READ THE FIRST 44 BYTES THAT ARE GUARANTEED
const Wav = struct {
    const WavHeader = struct {
        const Self = @This();
    };

    const Self = @This();

    RIFF_ChunkDescriptor: []u8,
    fmt_SubChunk: []u8,
    data_SubChunk: []u8,
};

pub fn main() !void {
    // var dir = try std.fs.cwd().openDir(public_path, .{});
    // const file_size: u64 = (try dir.stat()).size;
    // std.log.info("size of dir: {d}", .{file_size});

    // var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    // const allocator = gpa.allocator();
    // defer {
    //     const deinit_status = gpa.deinit();
    //     //fail test; can't try in defer as defer is executed after we return
    //     if (deinit_status == .leak) @panic("GPA leaked");
    // }

    // const recv_buf = try allocator.alloc(u8, file_size);
    // defer allocator.free(recv_buf);
    // ------

    var buf: [std.fs.MAX_PATH_BYTES]u8 = undefined;
    const cwd = try std.os.getcwd(&buf);

    std.log.info("cwd: {s}", .{cwd});

    const filepath = "gespeaker_ΚΑΛΩΣ_ΗΡΘΑΤΕ_ΣΤΟ_LINUX.wav";

    var file = try std.fs.cwd().readFile(filepath, &buf);
    std.log.info("{s}", .{file});

    var wav1 = Wav;
    _ = wav1;

    for (file, 1..) |char, index| {
        std.log.info("{d} {c} {any} {b}", .{ index, char, char, char });
    }
    std.log.info("{any}", .{file});
    // defer file.close();

}

// http://soundfile.sapp.org/doc/WaveFormat/
// The header of a WAV (RIFF) file is 44 bytes long and has the following format:
// 1 - 4	“RIFF”	Marks the file as a riff file. Characters are each 1 byte long.
// 5 - 8	File size (integer)	Size of the overall file - 8 bytes, in bytes (32-bit unsigned integer). Typically, you’d fill this in after creation.
// 9 -12	“WAVE”	File Type Header. For our purposes, it always equals “WAVE”.
// 13-16	“fmt "	Format chunk marker. Includes trailing null
// 17-20	16	Length of format subchunk (unsigned 32bit integer). 16 or PCM. What if not PCM?
// 21-22	1	Type of format (1 is PCM) - 2 byte integer
// 23-24	2	Number of Channels - 2 byte integer
// 25-28	44100	Sample Rate - 32 byte integer. Common values are 44100 (CD), 48000 (DAT). Sample Rate = Number of Samples per second, or Hertz.
// 29-32	176400	(Sample Rate * BitsPerSample * Channels) / 8.
// 33-34	4	(BitsPerSample * Channels) / 8.1 - 8 bit mono2 - 8 bit stereo/16 bit mono4 - 16 bit stereo
// 35-36	16	Bits per sample
// 37-40	“data”	“data” chunk header. Marks the beginning of the data section.
// 41-44	File size (data)	Size of the data section.
// Sample values are given above for a 16-bit stereo source.
// Stereo is a two channel audio format that delivers different audio information on the left and right sides
// Higher bit depht needs higher volumes to start to distort
// A 16-bit digital audio has a maximum dynamic range of 96dB while a 24-bit depth will give us a maximum of 144dB
// 21-22	1	Type of format (1 is PCM) - 2 byte integer. Find what are the others
//
// https://www.lightlink.com/tjweber/StripWav/WAVE.html
// ALSO HOW TO MAKE OUT RIGHT FROM LEFT CHANNEL SAMPLES (IF NUM OF CHANNELS = 2)
//
// ADD LINKS FOR THE DATA THAT I GOT (https://docs.fileformat.com/audio/wav/ FOR THE FORMAT OF THE WAV)
