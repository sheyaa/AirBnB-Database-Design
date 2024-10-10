-- guest
CREATE TABLE "guest" (
   "id" INTEGER,
   "first_name" TEXT NOT NULL,
   "last_name" TEXT NOT NULL,
   "username" TEXT NOT NULL UNIQUE,
   "phone_number" TEXT NOT NULL UNIQUE,
   "email" TEXT NOT NULL UNIQUE,
   PRIMARY KEY("id")
);

-- host
CREATE TABLE "host" (
   "id" INTEGER,
   "first_name" TEXT NOT NULL,
   "last_name" TEXT NOT NULL,
   "host_since" TEXT,
   "username" TEXT NOT NULL UNIQUE,
   "phone_number" TEXT NOT NULL,
   "email" TEXT NOT NULL UNIQUE,
   PRIMARY KEY ("id")
);

-- amenities
CREATE TABLE "amenities" (
   "id" INTEGER,
   "property_type" TEXT NOT NULL,
   "urban_rural_suburban" TEXT NOT NULL,
   "square_footage" TEXT NOT NULL,
   "number_of_beds" INTEGER NOT NULL,
   "number_of_bedrooms" INTEGER NOT NULL,
   "number_of_bathrooms" REAL NOT NULL,
   "air_conditioning" TEXT CHECK("air_conditioning" IN ('yes', 'no')) NOT NULL
   "wifi" TEXT CHECK("air_conditioning" IN ('yes', 'no')) NOT NULL,
   "pets_allowed" TEXT CHECK("air_conditioning" IN ('yes', 'no')) NOT NULL,
   "smoke_free" TEXT CHECK("air_conditioning" IN ('yes', 'no')) NOT NULL,
   "parking" TEXT NOT NULL,
   "laundry_facilities" TEXT NOT NULL,
   "swimming_pool" TEXT CHECK("air_conditioning" IN ('yes', 'no')) NOT NULL,
   "accessibility" TEXT NOT NULL,
   PRIMARY KEY ("id")

);

-- property
CREATE TABLE "property" (
   "id" INTEGER,
   "host_id" INTEGER NOT NULL,
   "amenities_id" INTEGER NOT NULL,
   "property_name" TEXT NOT NULL,
   "street_number" TEXT NOT NULL,
   "street" TEXT NOT NULL,
   "city" TEXT NOT NULL,
   "state" TEXT NOT NULL,
   "zip_code" TEXT NOT NULL,
   "country" TEXT NOT NULL,
   PRIMARY KEY("id"),
   FOREIGN KEY("host_id") REFERENCES "host"("id"),
   FOREIGN KEY("amenities_id") REFERENCES "amenities"("id")
);

-- transactions
CREATE TABLE "transactions" (
   "id" INTEGER,
   "guest_id" INTEGER NOT NULL,
   "property_id" INTEGER NOT NULL,
   "billing_address" TEXT NOT NULL,
   "payment_type" TEXT NOT NULL,
   "payment_date" DATE NOT NULL,
   "amount_paid" NUMERIC NOT NULL,
   PRIMARY KEY("id"),
   FOREIGN KEY ("guest_id") REFERENCES "guest"("id"),
   FOREIGN KEY ("property_id") REFERENCES "property"("id")
);

-- reviews
CREATE TABLE "reviews" (
   "id" INTEGER,
   "guest_id" INTEGER NOT NULL,
   "property_id" INTEGER NOT NULL,
   "rating" INTEGER NOT NULL,
   "comments" TEXT,
   PRIMARY KEY ("id"),
   FOREIGN KEY ("guest_id") REFERENCES "guest"("id"),
   FOREIGN KEY ("property_id") REFERENCES "property"("id")
);


CREATE TABLE "bookings" (
   "id"  INTEGER,
   "guest_id" INTEGER NOT NULL,
   "property_id" INTEGER NOT NULL,
   "check_in_date" TEXT NOT NULL,
   "check_out_date" TEXT NOT NULL,
   PRIMARY KEY ("id"),
   FOREIGN KEY ("guest_id") REFERENCES "guest"("id"),
   FOREIGN KEY ("property_id") REFERENCES "property"("id")
);


--------------------------------------------------------
CREATE VIEW "all_bookings" AS
SELECT
    "property"."id",
    "property"."property_name",
    "bookings"."check_in_date",
    "bookings"."check_out_date"
FROM
    "property"
JOIN
    "bookings" ON "property"."id" = "bookings"."property_id";

--------------------------------------------------------
CREATE TRIGGER prevent_double_booking
BEFORE INSERT ON bookings
FOR EACH ROW
BEGIN
    -- Check if there's any overlap with existing bookings
    SELECT
        CASE
            WHEN EXISTS (
                SELECT 1
                FROM bookings
                WHERE property_id = NEW.property_id
                AND (
                    (NEW.check_in_date BETWEEN check_in_date AND check_out_date)
                    OR
                    (NEW.check_out_date BETWEEN check_in_date AND check_out_date)
                    OR
                    (check_in_date BETWEEN NEW.check_in_date AND NEW.check_out_date)
                )
            )
            THEN
                RAISE(ABORT, 'Booking overlaps with an existing booking')
        END;
END;

--------------------------------------------------------
-- Create indexes to speed common searches
CREATE INDEX "host_name_search" ON "host" ("first_name", "last_name");
CREATE INDEX "guest_name_search" ON "guest" ("first_name", "last_name");
CREATE INDEX "city_name_search" ON "property" ("city", "state");

--------------------------------------------------------
