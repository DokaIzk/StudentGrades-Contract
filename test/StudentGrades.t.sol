// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.29;

import {Test, console} from "forge-std/Test.sol";
import {StudentGrade} from "../src/StudentGrades.sol";

contract TestStudentGrade is Test {
    StudentGrade gradeSystem;
    address admin;
    address student1;
    address student2;

    function setUp() public {
        admin = address(this);
        gradeSystem = new StudentGrade();
    }

    function testOnlyAdminRegisterStudents() public {
        vm.prank(student1);
        vm.expectRevert(
            abi.encodeWithSelector(StudentGrade.OnlyAdmin.selector, "Only The Admin Can Call This Function")
        );
        gradeSystem.registerStudent(student1, "Starlight Ishaya", "CyberSecurity");
    }

    function testRegisterStudent() public {
        gradeSystem.registerStudent(student2, "Otowo Samuel", "EIE");
        (,,, bool exists,) = gradeSystem.students(student1);
        assertEq(exists, true);
    }

    function testStudentAlreadyRegistered() public {
        gradeSystem.registerStudent(student2, "Otowo Samuel", "EIE");
        vm.expectRevert(
            abi.encodeWithSelector(StudentGrade.StudentAlreadyRegistered.selector, "This Student Already Exists")
        );
        gradeSystem.registerStudent(student2, "Otowo Samuel", "EIE");
    }

    function testAssignScoreAndGradeCalculation() public {
        console.log("Hello");
        gradeSystem.registerStudent(student1, "Otowo Samuel", "EIE");

        gradeSystem.assignScores(student1, "AIR101", 95);
        gradeSystem.assignScores(student1, "EDS", 85);

        vm.prank(student1);
        StudentGrade.Grades grade = gradeSystem.getMyGrade();

        // vm.prank(student1);
        // string[] memory subjects = gradeSystem.viewMySubjects();

        // console.log("Number Of Subjects ", subjects.length);

        // for (uint i = 0; i < subjects.length; i++) {
        //     console.log("Subject:", subjects[i]);
        // }
        assertEq(uint256(grade), uint256(StudentGrade.Grades.A));
    }

    function testViewSubjects() public {
        gradeSystem.registerStudent(student1, "Emmanuel Nzuebe", "CS");
        gradeSystem.assignScores(student1, "MAT121", 97);
        gradeSystem.assignScores(student1, "CSC121", 93);

        vm.prank(student1);
        string[] memory subjects = gradeSystem.viewMySubjects();

        assertEq(subjects.length, 2);
        assertEq(subjects[0], "MAT121");
        assertEq(subjects[1], "CSC121");
    }

    function testScoreForSubject() public {
        gradeSystem.registerStudent(student1, "Otowo Samuel", "EIE");
        gradeSystem.assignScores(student1, "PHY111", 87);

        vm.prank(student1);
        uint256 score = gradeSystem.scoreForSubject("PHY111");
        assertEq(score, 87);
    }

    function testScoreForNonExistentSubjectl() public {
        gradeSystem.registerStudent(student1, "Otowo Samuel", "EIE");

        vm.prank(student1);
        vm.expectRevert(abi.encodeWithSelector(StudentGrade.SubjectNotFound.selector, "Subject not found"));
        gradeSystem.scoreForSubject("BIO111");
    }

    function testGetGradeWithoutSubjects() public {
        gradeSystem.registerStudent(student1, "Otowo Samuel", "EIE");
        vm.prank(student1);
        StudentGrade.Grades grade = gradeSystem.getMyGrade();
        assertEq(uint256(grade), uint256(StudentGrade.Grades.F));
    }
}
