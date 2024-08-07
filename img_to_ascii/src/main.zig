const std = @import("std");
const zigimg = @import("zigimg");

const ascii_character_map = enum {
    light_characters,
    medium_characters,
    dark_characters,
};
// An enum to define the different types of character brightness.

const dark_chars = "mwqpdbkhao*#MW&%B@$";
const med_chars = "tfjrxnuvczXYUJCLQ0OZ";
const light_chars = "`^,:;Il!i~+";
const line_break: []const u8 = "\n";
// Character sets for the image.

const imageGeneration = struct {
    pub fn convertImgPixels(image: zigimg.Image, gen_allocator: anytype) !void {
        var colour_it = image.iterator();
        var ascii_img = std.ArrayList([]const u8).init(gen_allocator);
        var pixel_index: i32 = 0;
        // Makes the iterator for the image pixels, the dynamic array to hold the ASCII characters and the index of the current pixel.

        defer ascii_img.deinit();
        // Deinitialises the array once the function is finished.

        while (colour_it.next()) |color| {
            const lum_val = calculateLuminanceValue(color);
            try ascii_img.append(getChar(lum_val));
            // Calculates the luminance value of the pixel, then appends the chosen character to the array of the ASCII image.

            pixel_index += 1;

            if (@mod(pixel_index - 1, 100) == 0) { // The width of the image must replace the second value in @mod.
                try ascii_img.append(line_break);
                // Inserts a line break if the current character is at the edge of the image.
            }
        }

        try writingImageToFile(ascii_img);
    }

    fn getChar(luminance_value: f32) []const u8 {
        var pixel_type: ascii_character_map = undefined;
        var selected_char: []const u8 = undefined;
        // Variables that define the type (brightness) of the pixel and the chosen character.

        if (luminance_value <= 75) {
            pixel_type = ascii_character_map.dark_characters;
        } else if (luminance_value <= 150) {
            pixel_type = ascii_character_map.medium_characters;
        } else if (150 < luminance_value) {
            pixel_type = ascii_character_map.light_characters;
        }
        // Chooses the appropriate character set based on its brightness.

        switch (pixel_type) {
            .dark_characters => selected_char = selectingChar(luminance_value, dark_chars),
            .medium_characters => selected_char = selectingChar(luminance_value, med_chars),
            .light_characters => selected_char = selectingChar(luminance_value, light_chars),
        }

        return selected_char;
        // Selects a character from the appropriate character list based on its pixel brightness and returns the character.
    }

    fn selectingChar(luminance_value: f32, draw_char: []const u8) []const u8 {
        var char_index: usize = @intFromFloat(luminance_value);
        // Turns the f32 luminance value to a usize type to index the character list.

        if (char_index > draw_char.len - 1) {
            char_index = draw_char.len - 1;
        }
        // If the index exceeds the length of the char list, it's given the index of the final character.

        return draw_char[char_index .. char_index + 1];
        // Returns a slice of the character.
    }

    fn calculateLuminanceValue(colour: zigimg.color.Colorf32) f32 {
        return (0.2126 * (colour.r * 255) + 0.7152 * (colour.g * 255) + 0.0722 * (colour.b * 255));
        // Converts the f32 colour back into a 0-255 value, then uses it to calculate the luminance value.
    }
};

pub fn main() !void {
    var gen_purpose_allocator = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gen_purpose_allocator.deinit();

    const mem_allocator = gen_purpose_allocator.allocator();
    // Memory allocator for the image and the dynamic array.

    var base_image = try zigimg.Image.fromFilePath(mem_allocator, "absolute/path/to/image.png");
    defer base_image.deinit();
    // Gathers the image from the absolute file path.

    try imageGeneration.convertImgPixels(base_image, mem_allocator);
}

fn writingImageToFile(image_array: anytype) !void {
    const image_file = try std.fs.cwd().createFile(
        "ascii-img.txt",
        .{ .read = false },
    );
    defer image_file.close();
    // Creates a file for holding the generated text.

    for (image_array.items) |character| {
        try image_file.writeAll(character);
        // Writes the current character to the file.
    }

    std.debug.print("Successfully written!", .{});
    // Confirmation that the image was successfully written.
}
