final createVisit = """CREATE TABLE Visit (
    id_visit INTEGER IDENTITY,
    name_visit TEXT NOT NULL,
    start_date TEXT NOT NULL,
    end_date TEXT NOT NULL,
    nb_days INTEGER,
    PRIMARY KEY(id_visit)
);""";

final createDof = """CREATE TABLE DayOfVisit (
    id_day INTEGER,
    id_visit INTEGER,
    date_day TEXT,
    num_day INTEGER,
    PRIMARY KEY(id_day),
    FOREIGN KEY(id_visit) REFERENCES VISIT(id_visit)
    ON DELETE CASCADE
);""";

final createMeal = """CREATE TABLE Meal (
  id_meal INTEGER,
  id_day INTEGER,
  name_meal TEXT,
  total_price REAL,
  PRIMARY KEY(id_meal),
  FOREIGN KEY(id_day) REFERENCES DayOfVisit(id_day)
  ON DELETE CASCADE
);""";

final createFood = """CREATE TABLE Food (
  id_food INTEGER,
  id_meal INTEGER,
  name_food TEXT,
  brands_name TEXT,
  price REAL,
  quantity INTEGER,
  PRIMARY KEY(id_food),
  FOREIGN KEY(id_meal) REFERENCES Meal(id_meal)
  ON DELETE CASCADE
);""";

final createTriggerOnInsertFood = """CREATE TRIGGER on_update_food
AFTER INSERT ON Food
BEGIN
  UPDATE Meal SET total_price = total_price + (new.quantity * new.price) WHERE id_meal = new.id_meal;
END;""";

final createTriggerOnDeleteFood = """CREATE TRIGGER on_delete_food
AFTER DELETE ON Food
BEGIN
  UPDATE Meal SET total_price = total_price - (old.quantity * old.price) WHERE id_meal = old.id_meal;
END;""";
/*

CREATE TABLE MEAL (
    id_meal INTEGER,
    id_day INTEGER,
    name_meal TEXT NOT NULL,
    total_price REAL,
    PRIMARY KEY(id_meal),
    FOREIGN KEY(id_day) REFERENCES DAYOFVISIT(id_day)
)

CREATE TABLE FOOD (
    id_food INTEGER,
    id_meal INTEGER,
    name_food TEXT NOT NULL,
    price REAL NOT NULL,
    quantity INTEGER NOT NULL,
    PRIMARY KEY(id_food),
    FOREIGN KEY(id_meal) REFERENCES MEAL(id_meal)
)

CREATE TABLE BATCH (
    id_batch INTEGER,
    id_food INTEGER,
    PRIMARY KEY(id_batch)
)""";

*/