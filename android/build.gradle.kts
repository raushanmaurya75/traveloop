allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Fix for isar_flutter_libs missing namespace (incompatible with AGP 8+)
subprojects {
    afterEvaluate {
        if (project.hasProperty("android")) {
            val androidExt = project.extensions.findByName("android")
            if (androidExt is com.android.build.gradle.LibraryExtension) {
                if (androidExt.namespace == null) {
                    androidExt.namespace = project.group.toString().ifEmpty { "com.isar.${project.name.replace("-", "_")}" }
                }
                // Force compileSdk to match app for lStar attribute compatibility
                androidExt.compileSdk = 35
            }
        }
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
