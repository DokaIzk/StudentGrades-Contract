// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.29;

contract StudentGrade {
    address public admin;

    error OnlyAdmin(string reason);
    error UnauthorizedCaller(string reason);
    error StudentAlreadyRegistered(string reason);
    error StudentNotFound(string reason);
    error SubjectNotFound(string reason);

    enum Grades {
        F,
        D,
        C,
        B,
        A
    }

    struct Student {
        string name;
        string level;
        string course;
        bool exists;
        string[] subjects;
        Grades currentGrade;
    }

    mapping(address => Student) public students;
    mapping(address => mapping(string => uint256)) public subjectScores;

    constructor() {
        admin = msg.sender;
    }

    modifier AdminOnly() {
        if (msg.sender != admin) revert OnlyAdmin("Only The Admin Can Call This Function");
        _;
    }

    modifier OnlyStudentOrAdmin() {
        if (msg.sender != admin && !students[msg.sender].exists) {
            revert UnauthorizedCaller("You're Not Authorized To Call This Function");
        }
        _;
    }

    function registerStudent(address _student, string memory _name, string memory _course) external AdminOnly {
        if (students[_student].exists) revert StudentAlreadyRegistered("This Student Already Exists");

        students[_student] = Student({
            name: _name,
            level: "Level 1",
            course: _course,
            exists: true,
            subjects: new string[](0),
            currentGrade: Grades.F
        });
    }

    function assignScores(address _student, string calldata _subject, uint256 _score) external AdminOnly {
        if (!students[_student].exists) revert StudentNotFound("Student Not Found");
        if (subjectScores[_student][_subject] == 0) {
            students[_student].subjects.push(_subject);
        }

        subjectScores[_student][_subject] = _score;

        updateGrade(_student);
    }

    function updateGrade(address _student) internal {
        Student storage student = students[_student];
        uint256 total;
        uint256 count = student.subjects.length;

        for (uint256 i = 0; i < count; i++) {
            total += subjectScores[_student][student.subjects[i]];
        }

        uint256 AvgScore = total / count;

        if (AvgScore >= 90) {
            student.currentGrade = Grades.A;
        } else if (AvgScore >= 75) {
            student.currentGrade = Grades.B;
        } else if (AvgScore >= 60) {
            student.currentGrade = Grades.C;
        } else if (AvgScore >= 45) {
            student.currentGrade = Grades.D;
        } else {
            student.currentGrade = Grades.F;
        }
    }

    function scoreForSubject(string calldata _subject) external view OnlyStudentOrAdmin returns (uint256) {
        bool found = false;
        for (uint256 i = 0; i < students[msg.sender].subjects.length; i++) {
            if (keccak256(bytes(students[msg.sender].subjects[i])) == keccak256(bytes(_subject))) {
                found = true;
                break;
            }
        }
        if (!found) revert SubjectNotFound("Subject not found");

        return subjectScores[msg.sender][_subject];
    }

    function viewMySubjects() external view OnlyStudentOrAdmin returns (string[] memory) {
        return students[msg.sender].subjects;
    }

    function getMyGrade() external view OnlyStudentOrAdmin returns (Grades) {
        return students[msg.sender].currentGrade;
    }
}
