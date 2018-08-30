DROP VIEW IF EXISTS q0, q1i, q1ii, q1iii, q1iv, q2i, q2ii, q2iii, q3i, q3ii, q3iii, q4i, q4ii, q4iii, q4iv, q4v;

-- Question 0
CREATE VIEW q0(era)
AS
  SELECT MAX(era)
  FROM pitching
;

-- Question 1i
CREATE VIEW q1i(namefirst, namelast, birthyear)
AS
  SELECT namefirst, namelast, birthyear
  FROM master
  WHERE weight > 300
;

-- Question 1ii
-- there is a diff because sorting based on punctuation is different
CREATE VIEW q1ii(namefirst, namelast, birthyear)
AS
  SELECT namefirst, namelast, birthyear
  FROM master
  WHERE namefirst LIKE '% %'
  order by namefirst
;

-- Question 1iii
CREATE VIEW q1iii(birthyear, avgheight, count)
AS
  SELECT birthyear, AVG(height), count(*)
  FROM master
  Group by birthyear
  order by birthyear
;

-- Question 1iv
CREATE VIEW q1iv(birthyear, avgheight, count)
AS
  SELECT birthyear, AVG(height), count(*)
  FROM master
  Group by birthyear
  having AVG(height) > 70
  order by birthyear
;

-- Question 2i
CREATE VIEW q2i(namefirst, namelast, playerid, yearid)
AS
  SELECT namefirst, namelast, master.playerid, yearid
  FROM master
  INNER JOIN halloffame on master.playerid = halloffame.playerid
  WHERE inducted = 'Y'
  order by yearid desc
;

-- Question 2ii
CREATE VIEW q2ii(namefirst, namelast, playerid, schoolid, yearid)
AS
  SELECT namefirst, namelast, master.playerid, schools.schoolid, halloffame.yearid
  FROM master
  INNER JOIN halloffame on master.playerid = halloffame.playerid
  INNER JOIN collegeplaying on master.playerid = collegeplaying.playerid
  INNER JOIN schools on schools.schoolid = collegeplaying.schoolid
  WHERE inducted = 'Y'
    AND schools.schoolstate = 'CA'
  order by halloffame.yearid desc, master.playerid, schools.schoolid
;

-- Question 2iii
CREATE VIEW q2iii(playerid, namefirst, namelast, schoolid)
AS
  SELECT master.playerid, namefirst, namelast, collegeplaying.schoolid
  FROM master
  INNER JOIN halloffame on master.playerid = halloffame.playerid
  LEFT OUTER JOIN collegeplaying on master.playerid = collegeplaying.playerid
  WHERE inducted = 'Y'
  order by master.playerid desc, schoolid
;

-- Question 3i
-- seems like they have the wrong answers?
CREATE VIEW q3i(playerid, namefirst, namelast, yearid, slg)
AS
  SELECT master.playerid, namefirst, namelast, yearid, (0.0 + h + 2 * h2b + 3 * h3b + 4 * hr) / ab AS slg
  FROM master
  INNER JOIN batting on master.playerid = batting.playerid
  WHERE ab > 50
  order by slg desc, yearid, master.playerid
  limit 10
;

-- Question 3ii
CREATE VIEW q3ii(playerid, namefirst, namelast, lslg)
AS
  SELECT master.playerid, namefirst, namelast, (0.0 + h + 2 * h2b + 3 * h3b + 4 * hr) / ab AS slg
  FROM master
  INNER JOIN (
    SELECT playerid, sum(h) as h, sum(h2b) as h2b, sum(h3b) as h3b, sum(hr) as hr, sum(ab) as ab
    from batting
    group by playerid
  ) as battingTot on master.playerid = battingTot.playerid
  WHERE ab > 50
  order by slg desc, master.playerid
  limit 10
;

-- Question 3iii
CREATE VIEW q3iii(namefirst, namelast, lslg)
AS
  SELECT namefirst, namelast, (0.0 + h + 2 * h2b + 3 * h3b + 4 * hr) / ab AS slg
  FROM master
  INNER JOIN (
    SELECT playerid, sum(h) as h, sum(h2b) as h2b, sum(h3b) as h3b, sum(hr) as hr, sum(ab) as ab
    from batting
    group by playerid
  ) as battingTot on master.playerid = battingTot.playerid
  WHERE ab > 50
    AND (0.0 + h + 2 * h2b + 3 * h3b + 4 * hr) / ab >= (
      SELECT (0.0 + sum(h) + 2 * sum(h2b) + 3 * sum(h3b) + 4 * sum(hr)) / sum(ab)
      FROM batting
      group by playerid
      having playerid = 'mayswi01'
      limit 1
    )
  order by slg desc, master.playerid
;

-- Question 4i
CREATE VIEW q4i(yearid, min, max, avg, stddev)
AS
  SELECT yearid, min(salary), max(salary), avg(salary), stddev(salary)
  from salaries
  group by yearid
  order by yearid
;

-- Question 4ii
CREATE VIEW q4ii(binid, low, high, count)
AS
  SELECT 1, 1, 1, 1 -- replace this line
;

-- Question 4iii
CREATE VIEW q4iii(yearid, mindiff, maxdiff, avgdiff)
AS
  SELECT
    thisYear.yearid,
    thisYear.minSalary - lastYear.minSalary as mindiff,
    thisYear.maxSalary - lastYear.maxSalary as maxdiff,
    thisYear.avgSalary - lastYear.avgSalary as avgdiff
  FROM (
    SELECT yearid, min(salary) as minSalary, max(salary) as maxSalary, avg(salary) as avgSalary
    from salaries
    group by yearid
  ) as thisYear
  JOIN (
    SELECT yearid, min(salary) as minSalary, max(salary) as maxSalary, avg(salary) as avgSalary
    from salaries
    group by yearid
  ) as lastYear on thisYear.yearid = lastYear.yearid + 1
  order by thisYear.yearid
;

-- Question 4iv
CREATE VIEW q4iv(playerid, namefirst, namelast, salary, yearid)
AS
  SELECT master.playerid, namefirst, namelast, salaries.salary, salaries.yearid
  FROM master
  JOIN salaries on master.playerid = salaries.playerid
  JOIN (
    select yearid, max(salary) as salary
    FROM salaries
    group by yearid
  ) as maxSalariesPerYear on maxSalariesPerYear.yearid = salaries.yearid
  WHERE maxSalariesPerYear.yearid in (2000, 2001)
    AND salaries.salary >= maxSalariesPerYear.salary
;
-- Question 4v
CREATE VIEW q4v(team, diffAvg) AS
  SELECT maxSalary.teamid, maxSalary.salary - minSalary.salary
  FROM (
    SELECT allstarfull.yearid, allstarfull.teamid, min(salary) as salary
    from salaries
    join allstarfull on allstarfull.playerid = salaries.playerid AND allstarfull.yearid = salaries.yearid AND allstarfull.teamid = allstarfull.teamid
    group by allstarfull.teamid, allstarfull.yearid
    having allstarfull.yearid = 2016
  ) as minSalary
  JOIN (
    SELECT allstarfull.yearid, allstarfull.teamid, max(salary) as salary
    from salaries
    join allstarfull on allstarfull.playerid = salaries.playerid AND allstarfull.yearid = salaries.yearid AND allstarfull.teamid = allstarfull.teamid
    group by allstarfull.teamid, allstarfull.yearid
    having allstarfull.yearid = 2016
  ) as maxSalary on minSalary.yearid = maxSalary.yearid AND minSalary.teamid = maxSalary.teamid
;
