/**
 *
 */
module cashew.cashew_version;

private import std.conv: to;


/**
 *
 */
enum size_t cashewMajorVersion = 0u;


/**
 *
 */
enum size_t cashewMinorVersion = 1u;


/**
 *
 */
enum string cashewVersion = cashewMajorVersion.to!string ~ `.` ~ cashewMinorVersion.to!string;

