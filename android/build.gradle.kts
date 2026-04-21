// Top-level build file.
// Redirect every subproject's build dir up to $PROJECT_ROOT/build so the
// Flutter tool can find the APK at the path it expects. This matches the
// modern flutter-create template; without it, gradle writes to
// android/app/build/... and `flutter build apk` reports
// "Gradle build failed to produce an .apk file".

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
