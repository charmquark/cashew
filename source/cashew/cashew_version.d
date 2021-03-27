/**
 *
 */
module cashew.cashew_version;

/**
 *
 */
struct CashewVersion {
    import std.conv: to;

    /**
     *
     */
    static enum size_t major = 0u;

    /**
     *
     */
    static enum size_t minor = 1u;

    /**
     *
     */
    static enum string versionString = major.to!string ~ `.` ~ minor.to!string;

} // end cashewVersion
