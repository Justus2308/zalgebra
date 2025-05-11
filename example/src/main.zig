const std = @import("std");
const za = @import("zalgebra");
const Vec3 = za.Vec3;
const Mat4 = za.Mat4;

pub fn main() !void {
    try bench();
}

test "simple test" {
    const vec1 = Vec3.new(1, 2, 3);
    try std.testing.expectEqual(vec1.z(), 3);
}

const zbench = @import("zbench");
fn bench() !void {
    var bm = zbench.Benchmark.init(std.heap.page_allocator, .{ .time_budget_ns = 5e9 });
    defer bm.deinit();

    try bm.add("cross old", crossOld, .{});
    try bm.add("cross new", crossNew, .{});

    try bm.run(std.io.getStdOut().writer());
}

fn crossOld(allocator: std.mem.Allocator) void {
    var list_in1 = getRandomArrayList(za.Vec3, allocator, 0);
    defer list_in1.deinit(allocator);

    var list_in2 = getRandomArrayList(za.Vec3, allocator, 100);
    defer list_in2.deinit(allocator);

    var list_out = getUndefArrayList(za.Vec3, allocator);
    defer list_out.deinit(allocator);

    for (list_in1.items, list_in2.items, list_out.items) |vec_in1, vec_in2, *vec_out| {
        vec_out.* = cross(vec_in1, vec_in2);
    }
}

fn crossNew(allocator: std.mem.Allocator) void {
    var list_in1 = getRandomArrayList(za.Vec3, allocator, 0);
    defer list_in1.deinit(allocator);

    var list_in2 = getRandomArrayList(za.Vec3, allocator, 100);
    defer list_in2.deinit(allocator);

    var list_out = getUndefArrayList(za.Vec3, allocator);
    defer list_out.deinit(allocator);

    for (list_in1.items, list_in2.items, list_out.items) |vec_in1, vec_in2, *vec_out| {
        vec_out.* = vec_in1.cross(vec_in2);
    }
}

const vec_count = (1 << 20);

pub noinline fn getRandomArrayList(comptime T: type, allocator: std.mem.Allocator, seed: u64) std.ArrayListUnmanaged(T) {
    const list = getUndefArrayList(T, allocator);
    var rand = std.Random.DefaultPrng.init(seed);
    rand.fill(std.mem.sliceAsBytes(list.items));
    return list;
}

pub noinline fn getUndefArrayList(comptime T: type, allocator: std.mem.Allocator) std.ArrayListUnmanaged(T) {
    var list = std.ArrayListUnmanaged(T).initCapacity(allocator, vec_count) catch @panic("OOM");
    list.expandToCapacity();
    return list;
}

pub fn cross(first_vector: za.Vec3, second_vector: za.Vec3) za.Vec3 {
    const x1 = first_vector.x();
    const y1 = first_vector.y();
    const z1 = first_vector.z();

    const x2 = second_vector.x();
    const y2 = second_vector.y();
    const z2 = second_vector.z();

    const result_x = (y1 * z2) - (z1 * y2);
    const result_y = (z1 * x2) - (x1 * z2);
    const result_z = (x1 * y2) - (y1 * x2);
    return .new(result_x, result_y, result_z);
}
